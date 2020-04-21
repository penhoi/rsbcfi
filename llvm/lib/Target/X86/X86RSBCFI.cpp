#include "X86.h"
#include "X86InstrInfo.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

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

  for (auto &MBB : MF) {
    outs() << "Contents of MachineBasicBlock:\n";
    outs() << MBB << "\n";
    const BasicBlock *BB = MBB.getBasicBlock();
    outs() << "Contents of BasicBlock corresponding to MachineBasicBlock:\n";
    outs() << *BB << "\n";
  }

  return false;
}

} // end of anonymous namespace

namespace llvm {

FunctionPass *createX86RSBCFI() { return new X86RSBCFI(); }

} // namespace llvm
