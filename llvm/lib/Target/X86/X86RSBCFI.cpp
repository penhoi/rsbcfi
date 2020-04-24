#include "X86.h"
#include "X86InstrInfo.h"
#include "X86Subtarget.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/Target/TargetMachine.h"
#include <algorithm>
#include <string>

using namespace llvm;
using namespace std;

namespace {

class X86RSBCFI : public MachineFunctionPass {
public:
  static char ID;
  static bool bCFI;
  static string tmpInstCall;
  static string tmpInstRet;

  X86RSBCFI() : MachineFunctionPass(ID) {
    // initializeX86RSBCFIPass(*PassRegistry::getPassRegistry());
    const char *strEnv;

    strEnv = getenv("RSBCFI_ENFORCE");
    if (strEnv != NULL)
      bCFI = true;

    strEnv = getenv("RSBCFI_THRESVAL1");
    if (strEnv != NULL)
      replace_substr(tmpInstCall, "200", strEnv);

    strEnv = getenv("RSBCFI_THRESVAL2");
    if (strEnv != NULL)
      replace_substr(tmpInstCall, "800", strEnv);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

private:
  bool replace_substr(string &str, const string &from, const string &to) {
    size_t start_pos = str.find(from);
    if (start_pos == string::npos)
      return false;
    str.replace(start_pos, from.length(), to);
    return true;
  }
};

char X86RSBCFI::ID = 0;
bool X86RSBCFI::bCFI = false;

/* ----benign----200----unknow----800----attack---- */
std::string X86RSBCFI::tmpInstCall = "xtest\n\t"
                                     "jz 1f\n\t"
                                     "mov %eax, %ecx\n\t"
                                     "rdtsc\n\t"
                                     "sub %ecx, %eax\n\t"
                                     "cmp $$200, %eax\n\t"
                                     "jl 2f\n\t"
                                     "cmp $$800, %eax\n\t"
                                     "ja 3f\n\t"
                                     "xabort $$0x33\n\t"
                                     "3:\n\t"
                                     "xabort $$0x44\n\t"
                                     "2:\n\t"
                                     "xend\n\t"
                                     "xchg %rax, %r11\n\t"
                                     "1:\n\t";

std::string X86RSBCFI::tmpInstRet = "xchg %rax, %r11\n\t"
                                    "clflush (%rsp)\n\t"
                                    "mfence\n\t"
                                    "xbegin tsx_handler\n\t"
                                    "rdtsc\n\t";

bool X86RSBCFI::runOnMachineFunction(MachineFunction &MF) {
  if (!bCFI)
    return false;

  const TargetMachine *TM = &MF.getTarget();
  if (TM->getTargetTriple().getArch() != Triple::x86_64)
    return false;

  const X86Subtarget *STI = &MF.getSubtarget<X86Subtarget>();
  const X86InstrInfo *TII = STI->getInstrInfo();

#define RSBCFI_INSTRUMENT(MI, strAsm)                                          \
  do {                                                                         \
    MachineInstrBuilder MIB =                                                  \
        BuildMI(MBB, MI, DebugLoc(), TII->get(X86::INLINEASM));                \
    MIB.addExternalSymbol(strAsm.c_str());                                     \
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
        RSBCFI_INSTRUMENT(MI, tmpInstCall);

      if (MI.isCall())
        preCall = &MI;
      else
        preCall = NULL;
    }
    if (preCall != NULL)
      RSBCFI_INSTRUMENT(MBB.end(), tmpInstCall);
  }

  /* Do instrumentation before a RETURN */
  if (!MF.getFunction().hasExternalLinkage()) {
    for (auto &MBB : MF) {
      MachineInstr &MI = MBB.back();
      if (MI.isReturn())
        RSBCFI_INSTRUMENT(MI, tmpInstRet);
    }
  }

  return false;
} // namespace

} // end of anonymous namespace

namespace llvm {

FunctionPass *createX86RSBCFI() { return new X86RSBCFI(); }

} // namespace llvm
