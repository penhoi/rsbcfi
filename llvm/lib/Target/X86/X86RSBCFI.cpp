#include "X86.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetMachine.h"

using namespace llvm;

namespace {

class X86RSBCFI : public MachineFunctionPass {
public:
  static char ID;
  static bool bCFI;

  X86RSBCFI() : MachineFunctionPass(ID) {
    // initializeX86RSBCFIPass(*PassRegistry::getPassRegistry());
    const char *szCFI = getenv("RSBCFI");
    if (szCFI != NULL)
      bCFI = true;
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

char X86RSBCFI::ID = 0;
bool X86RSBCFI::bCFI = false;

bool X86RSBCFI::runOnMachineFunction(MachineFunction &MF) {
  if (!bCFI)
    return false;

  const TargetMachine *TM = &MF.getTarget();
  if (TM->getTargetTriple().getArch() != Triple::x86_64)
    return false;

  const X86Subtarget *STI = &MF.getSubtarget<X86Subtarget>();
  const X86InstrInfo *TII = STI->getInstrInfo();
  const char *strInstCall = "xtest\n\t"
                            "jz 2f\n\t"
                            "mov %eax, %ecx\n\t"
                            "rdtsc\n\t"
                            "sub %ecx, %eax\n\t"
                            "cmp $$1000, %eax\n\t"
                            "jl 1f\n\t"
                            "xabort $$33\n\t"
                            "1:\n\t"
                            "xchg %rax, %r11\n\t"
                            "xend\n\t"
                            "2:\n\t";

  const char *strInstRet = "xchg %rax, %r11\n\t"
                           "clflush (%rsp)\n\t"
                           "mfence\n\t"
                           "xbegin tsx_handler\n\t"
                           "rdtsc\n\t";

#define RSBCFI_CALL_INSTR(MI)                                                  \
  do {                                                                         \
    MachineInstrBuilder MIB =                                                  \
        BuildMI(MBB, MI, DebugLoc(), TII->get(X86::INLINEASM));                \
    MIB.addExternalSymbol(strInstCall);                                        \
    MIB.addImm(ISD::EntryToken);                                               \
    MIB.addImm(ISD::Register | InlineAsm::Kind_Clobber);                       \
    MIB.addReg(X86::EFLAGS, RegState::Define | RegState::EarlyClobber |        \
                                RegState::Implicit);                           \
  } while (0);

#define RSBCFI_RET_INSTR(MI)                                                   \
  do {                                                                         \
    MachineInstrBuilder MIB =                                                  \
        BuildMI(MBB, MI, DebugLoc(), TII->get(X86::INLINEASM));                \
    MIB.addExternalSymbol(strInstRet);                                         \
    MIB.addImm(ISD::EntryToken);                                               \
    MIB.addImm(ISD::Register | InlineAsm::Kind_Clobber);                       \
    MIB.addReg(X86::EFLAGS, RegState::Define | RegState::EarlyClobber |        \
                                RegState::Implicit);                           \
  } while (0);

  /* Do instrumentation after a CALL */
  for (auto &MBB : MF) {
    MachineInstr *preCall = NULL;
    for (auto &MI : MBB) {
      if (preCall != NULL)
        RSBCFI_CALL_INSTR(MI);

      if (MI.isCall())
        preCall = &MI;
      else
        preCall = NULL;
    }
    if (preCall != NULL)
      RSBCFI_CALL_INSTR(MBB.end());
  }

  /* Do instrumentation before a RETURN */
  if (!MF.getFunction().hasExternalLinkage()) {
    for (auto &MBB : MF) {
      MachineInstr &MI = MBB.back();
      if (MI.isReturn())
        RSBCFI_RET_INSTR(MI);
    }
  }

  return false;
} // namespace

} // end of anonymous namespace

namespace llvm {

FunctionPass *createX86RSBCFI() { return new X86RSBCFI(); }

} // namespace llvm
