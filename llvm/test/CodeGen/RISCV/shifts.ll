; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV32I
; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefix=RV64I

; Basic shift support is tested as part of ALU.ll. This file ensures that
; shifts which may not be supported natively are lowered properly.

define i64 @lshr64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: lshr64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a3, a2, -32
; RV32I-NEXT:    bltz a3, .LBB0_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    srl a0, a1, a3
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB0_2:
; RV32I-NEXT:    srl a0, a0, a2
; RV32I-NEXT:    addi a3, zero, 31
; RV32I-NEXT:    sub a3, a3, a2
; RV32I-NEXT:    slli a4, a1, 1
; RV32I-NEXT:    sll a3, a4, a3
; RV32I-NEXT:    or a0, a0, a3
; RV32I-NEXT:    srl a1, a1, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: lshr64:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srl a0, a0, a1
; RV64I-NEXT:    ret
  %1 = lshr i64 %a, %b
  ret i64 %1
}

define i64 @lshr64_minsize(i64 %a, i64 %b) minsize nounwind {
; RV32I-LABEL: lshr64_minsize:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __lshrdi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV64I-LABEL: lshr64_minsize:
; RV64I:       # %bb.0:
; RV64I-NEXT:    srl a0, a0, a1
; RV64I-NEXT:    ret
  %1 = lshr i64 %a, %b
  ret i64 %1
}

define i64 @ashr64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: ashr64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a3, a2, -32
; RV32I-NEXT:    bltz a3, .LBB2_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    sra a0, a1, a3
; RV32I-NEXT:    srai a1, a1, 31
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB2_2:
; RV32I-NEXT:    srl a0, a0, a2
; RV32I-NEXT:    addi a3, zero, 31
; RV32I-NEXT:    sub a3, a3, a2
; RV32I-NEXT:    slli a4, a1, 1
; RV32I-NEXT:    sll a3, a4, a3
; RV32I-NEXT:    or a0, a0, a3
; RV32I-NEXT:    sra a1, a1, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: ashr64:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sra a0, a0, a1
; RV64I-NEXT:    ret
  %1 = ashr i64 %a, %b
  ret i64 %1
}

define i64 @ashr64_minsize(i64 %a, i64 %b) minsize nounwind {
; RV32I-LABEL: ashr64_minsize:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __ashrdi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV64I-LABEL: ashr64_minsize:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sra a0, a0, a1
; RV64I-NEXT:    ret
  %1 = ashr i64 %a, %b
  ret i64 %1
}

define i64 @shl64(i64 %a, i64 %b) nounwind {
; RV32I-LABEL: shl64:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi a3, a2, -32
; RV32I-NEXT:    bltz a3, .LBB4_2
; RV32I-NEXT:  # %bb.1:
; RV32I-NEXT:    sll a1, a0, a3
; RV32I-NEXT:    mv a0, zero
; RV32I-NEXT:    ret
; RV32I-NEXT:  .LBB4_2:
; RV32I-NEXT:    sll a1, a1, a2
; RV32I-NEXT:    addi a3, zero, 31
; RV32I-NEXT:    sub a3, a3, a2
; RV32I-NEXT:    srli a4, a0, 1
; RV32I-NEXT:    srl a3, a4, a3
; RV32I-NEXT:    or a1, a1, a3
; RV32I-NEXT:    sll a0, a0, a2
; RV32I-NEXT:    ret
;
; RV64I-LABEL: shl64:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sll a0, a0, a1
; RV64I-NEXT:    ret
  %1 = shl i64 %a, %b
  ret i64 %1
}

define i64 @shl64_minsize(i64 %a, i64 %b) minsize nounwind {
; RV32I-LABEL: shl64_minsize:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp)
; RV32I-NEXT:    call __ashldi3
; RV32I-NEXT:    lw ra, 12(sp)
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV64I-LABEL: shl64_minsize:
; RV64I:       # %bb.0:
; RV64I-NEXT:    sll a0, a0, a1
; RV64I-NEXT:    ret
  %1 = shl i64 %a, %b
  ret i64 %1
}

define i128 @lshr128(i128 %a, i128 %b) nounwind {
; RV32I-LABEL: lshr128:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -48
; RV32I-NEXT:    sw ra, 44(sp)
; RV32I-NEXT:    sw s0, 40(sp)
; RV32I-NEXT:    lw a2, 0(a2)
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    lw a4, 4(a1)
; RV32I-NEXT:    lw a5, 8(a1)
; RV32I-NEXT:    lw a1, 12(a1)
; RV32I-NEXT:    mv s0, a0
; RV32I-NEXT:    sw a1, 20(sp)
; RV32I-NEXT:    sw a5, 16(sp)
; RV32I-NEXT:    sw a4, 12(sp)
; RV32I-NEXT:    addi a0, sp, 24
; RV32I-NEXT:    addi a1, sp, 8
; RV32I-NEXT:    sw a3, 8(sp)
; RV32I-NEXT:    call __lshrti3
; RV32I-NEXT:    lw a0, 36(sp)
; RV32I-NEXT:    lw a1, 32(sp)
; RV32I-NEXT:    lw a2, 28(sp)
; RV32I-NEXT:    lw a3, 24(sp)
; RV32I-NEXT:    sw a0, 12(s0)
; RV32I-NEXT:    sw a1, 8(s0)
; RV32I-NEXT:    sw a2, 4(s0)
; RV32I-NEXT:    sw a3, 0(s0)
; RV32I-NEXT:    lw s0, 40(sp)
; RV32I-NEXT:    lw ra, 44(sp)
; RV32I-NEXT:    addi sp, sp, 48
; RV32I-NEXT:    ret
;
; RV64I-LABEL: lshr128:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi a3, a2, -64
; RV64I-NEXT:    bltz a3, .LBB6_2
; RV64I-NEXT:  # %bb.1:
; RV64I-NEXT:    srl a0, a1, a3
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB6_2:
; RV64I-NEXT:    srl a0, a0, a2
; RV64I-NEXT:    addi a3, zero, 63
; RV64I-NEXT:    sub a3, a3, a2
; RV64I-NEXT:    slli a4, a1, 1
; RV64I-NEXT:    sll a3, a4, a3
; RV64I-NEXT:    or a0, a0, a3
; RV64I-NEXT:    srl a1, a1, a2
; RV64I-NEXT:    ret
  %1 = lshr i128 %a, %b
  ret i128 %1
}

define i128 @ashr128(i128 %a, i128 %b) nounwind {
; RV32I-LABEL: ashr128:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -48
; RV32I-NEXT:    sw ra, 44(sp)
; RV32I-NEXT:    sw s0, 40(sp)
; RV32I-NEXT:    lw a2, 0(a2)
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    lw a4, 4(a1)
; RV32I-NEXT:    lw a5, 8(a1)
; RV32I-NEXT:    lw a1, 12(a1)
; RV32I-NEXT:    mv s0, a0
; RV32I-NEXT:    sw a1, 20(sp)
; RV32I-NEXT:    sw a5, 16(sp)
; RV32I-NEXT:    sw a4, 12(sp)
; RV32I-NEXT:    addi a0, sp, 24
; RV32I-NEXT:    addi a1, sp, 8
; RV32I-NEXT:    sw a3, 8(sp)
; RV32I-NEXT:    call __ashrti3
; RV32I-NEXT:    lw a0, 36(sp)
; RV32I-NEXT:    lw a1, 32(sp)
; RV32I-NEXT:    lw a2, 28(sp)
; RV32I-NEXT:    lw a3, 24(sp)
; RV32I-NEXT:    sw a0, 12(s0)
; RV32I-NEXT:    sw a1, 8(s0)
; RV32I-NEXT:    sw a2, 4(s0)
; RV32I-NEXT:    sw a3, 0(s0)
; RV32I-NEXT:    lw s0, 40(sp)
; RV32I-NEXT:    lw ra, 44(sp)
; RV32I-NEXT:    addi sp, sp, 48
; RV32I-NEXT:    ret
;
; RV64I-LABEL: ashr128:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi a3, a2, -64
; RV64I-NEXT:    bltz a3, .LBB7_2
; RV64I-NEXT:  # %bb.1:
; RV64I-NEXT:    sra a0, a1, a3
; RV64I-NEXT:    srai a1, a1, 63
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB7_2:
; RV64I-NEXT:    srl a0, a0, a2
; RV64I-NEXT:    addi a3, zero, 63
; RV64I-NEXT:    sub a3, a3, a2
; RV64I-NEXT:    slli a4, a1, 1
; RV64I-NEXT:    sll a3, a4, a3
; RV64I-NEXT:    or a0, a0, a3
; RV64I-NEXT:    sra a1, a1, a2
; RV64I-NEXT:    ret
  %1 = ashr i128 %a, %b
  ret i128 %1
}

define i128 @shl128(i128 %a, i128 %b) nounwind {
; RV32I-LABEL: shl128:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -48
; RV32I-NEXT:    sw ra, 44(sp)
; RV32I-NEXT:    sw s0, 40(sp)
; RV32I-NEXT:    lw a2, 0(a2)
; RV32I-NEXT:    lw a3, 0(a1)
; RV32I-NEXT:    lw a4, 4(a1)
; RV32I-NEXT:    lw a5, 8(a1)
; RV32I-NEXT:    lw a1, 12(a1)
; RV32I-NEXT:    mv s0, a0
; RV32I-NEXT:    sw a1, 20(sp)
; RV32I-NEXT:    sw a5, 16(sp)
; RV32I-NEXT:    sw a4, 12(sp)
; RV32I-NEXT:    addi a0, sp, 24
; RV32I-NEXT:    addi a1, sp, 8
; RV32I-NEXT:    sw a3, 8(sp)
; RV32I-NEXT:    call __ashlti3
; RV32I-NEXT:    lw a0, 36(sp)
; RV32I-NEXT:    lw a1, 32(sp)
; RV32I-NEXT:    lw a2, 28(sp)
; RV32I-NEXT:    lw a3, 24(sp)
; RV32I-NEXT:    sw a0, 12(s0)
; RV32I-NEXT:    sw a1, 8(s0)
; RV32I-NEXT:    sw a2, 4(s0)
; RV32I-NEXT:    sw a3, 0(s0)
; RV32I-NEXT:    lw s0, 40(sp)
; RV32I-NEXT:    lw ra, 44(sp)
; RV32I-NEXT:    addi sp, sp, 48
; RV32I-NEXT:    ret
;
; RV64I-LABEL: shl128:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi a3, a2, -64
; RV64I-NEXT:    bltz a3, .LBB8_2
; RV64I-NEXT:  # %bb.1:
; RV64I-NEXT:    sll a1, a0, a3
; RV64I-NEXT:    mv a0, zero
; RV64I-NEXT:    ret
; RV64I-NEXT:  .LBB8_2:
; RV64I-NEXT:    sll a1, a1, a2
; RV64I-NEXT:    addi a3, zero, 63
; RV64I-NEXT:    sub a3, a3, a2
; RV64I-NEXT:    srli a4, a0, 1
; RV64I-NEXT:    srl a3, a4, a3
; RV64I-NEXT:    or a1, a1, a3
; RV64I-NEXT:    sll a0, a0, a2
; RV64I-NEXT:    ret
  %1 = shl i128 %a, %b
  ret i128 %1
}
