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

  X86RSBCFI() : MachineFunctionPass(ID) {
    // initializeX86RSBCFIPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;
};

char X86RSBCFI::ID = 0;

bool X86RSBCFI::runOnMachineFunction(MachineFunction &MF) {
  const TargetMachine *TM = &MF.getTarget();
  if (TM->getTargetTriple().getArch() != Triple::x86_64)
    return false;

  const X86Subtarget *STI = &MF.getSubtarget<X86Subtarget>();
  const X86InstrInfo *TII = STI->getInstrInfo();

#define RSBCFI_CALL_INSTR(MI)                                                  \
  do {                                                                         \
    BuildMI(MBB, MI, DebugLoc(), TII->get(X86::NOOP));                         \
    BuildMI(MBB, MI, DebugLoc(), TII->get(X86::XTEST));                        \
  } while (0);

#define RSBCFI_RETL_INSTR(MI)                                                  \
  do {                                                                         \
    BuildMI(MBB, MI, DebugLoc(), TII->get(X86::NOOP));                         \
    BuildMI(MBB, MI, DebugLoc(), TII->get(X86::NOOP));                         \
  } while (0);

  for (auto &MBB : MF) {
    /* Do instrumentation after a CALL */
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

    /* Do instrumentation before a RETURN */
    MachineInstr &MI = MBB.back();
    if (MI.isReturn())
      RSBCFI_RETL_INSTR(MI);
  }

  return false;
} // namespace

} // end of anonymous namespace

namespace llvm {

FunctionPass *createX86RSBCFI() { return new X86RSBCFI(); }

} // namespace llvm
