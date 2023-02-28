; ModuleID = '/root/tmp/zkllvm/examples/arithmetics.cpp'
source_filename = "/root/tmp/zkllvm/examples/arithmetics.cpp"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "assigner"

$_ZN3nil7crypto37algebra6fields17pallas_base_field12modulus_bitsE = comdat any

$_ZN3nil7crypto37algebra6fields17pallas_base_field11number_bitsE = comdat any

$_ZN3nil7crypto37algebra6fields17pallas_base_field10value_bitsE = comdat any

$_ZN3nil7crypto37algebra6fields16vesta_base_field12modulus_bitsE = comdat any

$_ZN3nil7crypto37algebra6fields16vesta_base_field11number_bitsE = comdat any

$_ZN3nil7crypto37algebra6fields16vesta_base_field10value_bitsE = comdat any

@_ZZN3nil7crypto314multiprecision8backends11window_bitsEmE5wsize = internal unnamed_addr constant [6 x [2 x i64]] [[2 x i64] [i64 1434, i64 7], [2 x i64] [i64 539, i64 6], [2 x i64] [i64 197, i64 4], [2 x i64] [i64 70, i64 3], [2 x i64] [i64 17, i64 2], [2 x i64] zeroinitializer], align 8
@_ZN3nil7crypto37algebra6fields17pallas_base_field12modulus_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8
@_ZN3nil7crypto37algebra6fields17pallas_base_field11number_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8
@_ZN3nil7crypto37algebra6fields17pallas_base_field10value_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8
@_ZN3nil7crypto37algebra6fields16vesta_base_field12modulus_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8
@_ZN3nil7crypto37algebra6fields16vesta_base_field11number_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8
@_ZN3nil7crypto37algebra6fields16vesta_base_field10value_bitsE = weak_odr dso_local local_unnamed_addr constant i64 255, comdat, align 8

; Function Attrs: mustprogress nounwind
define dso_local noundef i64 @_ZN3nil7crypto314multiprecision8backends11window_bitsEm(i64 noundef %0) local_unnamed_addr #0 {
  br label %2

2:                                                ; preds = %2, %1
  %3 = phi i64 [ 5, %1 ], [ %8, %2 ]
  %4 = getelementptr inbounds [6 x [2 x i64]], [6 x [2 x i64]]* @_ZZN3nil7crypto314multiprecision8backends11window_bitsEmE5wsize, i64 0, i64 %3
  %5 = getelementptr inbounds [2 x i64], [2 x i64]* %4, i64 0, i64 0
  %6 = load i64, i64* %5, align 8, !tbaa !3
  %7 = icmp ugt i64 %6, %0
  %8 = add i64 %3, -1
  br i1 %7, label %2, label %9, !llvm.loop !7

9:                                                ; preds = %2
  %10 = phi i64 [ %3, %2 ]
  %11 = getelementptr inbounds [6 x [2 x i64]], [6 x [2 x i64]]* @_ZZN3nil7crypto314multiprecision8backends11window_bitsEmE5wsize, i64 0, i64 %10
  %12 = getelementptr inbounds [2 x i64], [2 x i64]* %11, i64 0, i64 1
  %13 = load i64, i64* %12, align 8, !tbaa !3
  %14 = add i64 1, %13
  ret i64 %14
}

; Function Attrs: mustprogress nounwind
define dso_local noundef __zkllvm_field_pallas_base @_Z3powu26__zkllvm_field_pallas_basei(__zkllvm_field_pallas_base noundef %0, i32 noundef %1) local_unnamed_addr #0 {
  %3 = icmp eq i32 %1, 0
  br i1 %3, label %4, label %5

4:                                                ; preds = %2
  br label %20

5:                                                ; preds = %2
  %6 = icmp slt i32 0, %1
  br i1 %6, label %7, label %10

7:                                                ; preds = %5
  br label %12

8:                                                ; preds = %16
  %9 = phi __zkllvm_field_pallas_base [ %15, %16 ]
  br label %10

10:                                               ; preds = %8, %5
  %11 = phi __zkllvm_field_pallas_base [ %9, %8 ], [ f0x1, %5 ]
  br label %19

12:                                               ; preds = %7, %16
  %13 = phi i32 [ 0, %7 ], [ %17, %16 ]
  %14 = phi __zkllvm_field_pallas_base [ f0x1, %7 ], [ %15, %16 ]
  %15 = mul __zkllvm_field_pallas_base %14, %0
  br label %16

16:                                               ; preds = %12
  %17 = add nsw i32 %13, 1
  %18 = icmp slt i32 %17, %1
  br i1 %18, label %12, label %8, !llvm.loop !10

19:                                               ; preds = %10
  br label %20

20:                                               ; preds = %19, %4
  %21 = phi __zkllvm_field_pallas_base [ f0x1, %4 ], [ %11, %19 ]
  ret __zkllvm_field_pallas_base %21
}

; Function Attrs: circuit mustprogress nounwind
define dso_local noundef __zkllvm_field_pallas_base @_Z24field_arithmetic_exampleu26__zkllvm_field_pallas_baseu26__zkllvm_field_pallas_base(__zkllvm_field_pallas_base noundef %0, __zkllvm_field_pallas_base noundef %1) local_unnamed_addr #1 {
  %3 = add __zkllvm_field_pallas_base %0, %1
  %4 = mul __zkllvm_field_pallas_base %3, %0
  %5 = add __zkllvm_field_pallas_base %0, %1
  %6 = mul __zkllvm_field_pallas_base %1, %5
  %7 = add __zkllvm_field_pallas_base %0, %1
  %8 = mul __zkllvm_field_pallas_base %6, %7
  %9 = add __zkllvm_field_pallas_base %4, %8
  %10 = mul __zkllvm_field_pallas_base %9, %9
  %11 = mul __zkllvm_field_pallas_base %10, %9
  %12 = sub __zkllvm_field_pallas_base %1, %0
  %13 = sdiv __zkllvm_field_pallas_base %11, %12
  %14 = tail call noundef __zkllvm_field_pallas_base @_Z3powu26__zkllvm_field_pallas_basei(__zkllvm_field_pallas_base noundef %0, i32 noundef 2)
  %15 = add __zkllvm_field_pallas_base %13, %14
  %16 = add __zkllvm_field_pallas_base %15, f0x12345678901234567890
  ret __zkllvm_field_pallas_base %16
}

attributes #0 = { mustprogress nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { circuit mustprogress nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"clang version 16.0.0 (git@github.com:NilFoundation/zkllvm-circifier.git 4d230ed398898e2328862fbde0e76a377d7d8884)"}
!3 = !{!4, !4, i64 0}
!4 = !{!"long", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = distinct !{!7, !8, !9}
!8 = !{!"llvm.loop.mustprogress"}
!9 = !{!"llvm.loop.unroll.disable"}
!10 = distinct !{!10, !8, !9}
