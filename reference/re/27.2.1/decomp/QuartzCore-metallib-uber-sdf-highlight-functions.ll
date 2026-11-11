define internal fastcc <4 x float> @_ZN10UberShaderIffE26vibrant_color_matrix_soverEDv4_fS1_PU11MTLconstantKS1_ff(<4 x float> noundef %0, <4 x float> noundef %1, ptr addrspace(2) noundef %2, float noundef %3, float noundef %4) unnamed_addr #4 align 2 {
  %6 = shufflevector <4 x float> %1, <4 x float> poison, <3 x i32> <i32 0, i32 1, i32 2>
  %7 = extractelement <4 x float> %1, i64 3
  %8 = tail call fast float @air.fast_fmax.f32(float %7, float 0x3EB0C6F7A0000000) #17
  %9 = insertelement <3 x float> poison, float %8, i64 0
  %10 = shufflevector <3 x float> %9, <3 x float> poison, <3 x i32> zeroinitializer
  %11 = fdiv fast <3 x float> %6, %10
  %12 = shufflevector <3 x float> %11, <3 x float> undef, <4 x i32> zeroinitializer
  %13 = load <4 x float>, ptr addrspace(2) %2, align 16, !tbaa !265
  %14 = fmul fast <4 x float> %12, %13
  %15 = shufflevector <3 x float> %11, <3 x float> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %16 = getelementptr inbounds <4 x float>, ptr addrspace(2) %2, i64 1
  %17 = load <4 x float>, ptr addrspace(2) %16, align 16, !tbaa !265
  %18 = fmul fast <4 x float> %15, %17
  %19 = fadd fast <4 x float> %14, %18
  %20 = shufflevector <3 x float> %11, <3 x float> undef, <4 x i32> <i32 2, i32 2, i32 2, i32 2>
  %21 = getelementptr inbounds <4 x float>, ptr addrspace(2) %2, i64 2
  %22 = load <4 x float>, ptr addrspace(2) %21, align 16, !tbaa !265
  %23 = fmul fast <4 x float> %20, %22
  %24 = fadd fast <4 x float> %19, %23
  %25 = shufflevector <4 x float> %1, <4 x float> undef, <4 x i32> <i32 3, i32 3, i32 3, i32 3>
  %26 = getelementptr inbounds <4 x float>, ptr addrspace(2) %2, i64 3
  %27 = load <4 x float>, ptr addrspace(2) %26, align 16, !tbaa !265
  %28 = fmul fast <4 x float> %27, %25
  %29 = fadd fast <4 x float> %24, %28
  %30 = getelementptr inbounds <4 x float>, ptr addrspace(2) %2, i64 4
  %31 = load <4 x float>, ptr addrspace(2) %30, align 16, !tbaa !265
  %32 = fadd fast <4 x float> %29, %31
  %33 = extractelement <4 x float> %32, i64 3
  %34 = tail call fast float @air.fast_saturate.f32(float %33) #17
  %35 = shufflevector <4 x float> %32, <4 x float> poison, <3 x i32> <i32 0, i32 1, i32 2>
  %36 = insertelement <3 x float> poison, float %34, i64 0
  %37 = shufflevector <3 x float> %36, <3 x float> poison, <3 x i32> zeroinitializer
  %38 = fmul fast <3 x float> %35, %37
  %39 = shufflevector <3 x float> %38, <3 x float> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %40 = insertelement <4 x float> %39, float %34, i64 3
  %41 = shufflevector <4 x float> %0, <4 x float> undef, <4 x i32> <i32 3, i32 3, i32 3, i32 3>
  %42 = fmul fast <4 x float> %40, %41
  %43 = fcmp fast ogt float %3, 0.000000e+00
  br i1 %43, label %44, label %89

44:                                               ; preds = %5
  %45 = fcmp fast ogt float %4, 0.000000e+00
  br i1 %45, label %46, label %75

46:                                               ; preds = %44
  %47 = shufflevector <4 x float> %42, <4 x float> poison, <3 x i32> <i32 0, i32 1, i32 2>
  %48 = extractelement <4 x float> %42, i64 3
  %49 = tail call fast float @air.fast_fmax.f32(float %48, float 0x3EB0C6F7A0000000) #17
  %50 = insertelement <3 x float> poison, float %49, i64 0
  %51 = shufflevector <3 x float> %50, <3 x float> poison, <3 x i32> zeroinitializer
  %52 = fdiv fast <3 x float> %47, %51
  %53 = shufflevector <3 x float> %52, <3 x float> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %54 = shufflevector <4 x float> %53, <4 x float> %42, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  %55 = extractelement <3 x float> %52, i64 0
  %56 = extractelement <3 x float> %52, i64 1
  %57 = tail call fast float @air.fast_fmax.f32(float %55, float %56) #17
  %58 = extractelement <3 x float> %52, i64 2
  %59 = tail call fast float @air.fast_fmax.f32(float %57, float %58) #17
  %60 = fcmp fast ogt float %59, %3
  br i1 %60, label %61, label %68

61:                                               ; preds = %46
  %62 = fdiv fast float %3, %59
  %63 = insertelement <3 x float> poison, float %62, i64 0
  %64 = shufflevector <3 x float> %63, <3 x float> poison, <3 x i32> zeroinitializer
  %65 = fmul fast <3 x float> %64, %52
  %66 = shufflevector <3 x float> %65, <3 x float> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %67 = shufflevector <4 x float> %66, <4 x float> %54, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  br label %68

68:                                               ; preds = %61, %46
  %69 = phi <4 x float> [ %67, %61 ], [ %54, %46 ]
  %70 = shufflevector <4 x float> %42, <4 x float> undef, <3 x i32> <i32 3, i32 3, i32 3>
  %71 = shufflevector <4 x float> %69, <4 x float> poison, <3 x i32> <i32 0, i32 1, i32 2>
  %72 = fmul fast <3 x float> %71, %70
  %73 = shufflevector <3 x float> %72, <3 x float> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %74 = shufflevector <4 x float> %73, <4 x float> %69, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  br label %89

75:                                               ; preds = %44
  %76 = extractelement <4 x float> %42, i64 3
  %77 = tail call fast float @air.fast_fmax.f32(float %76, float 0x3EB0C6F7A0000000) #17
  %78 = insertelement <3 x float> poison, float %77, i64 0
  %79 = shufflevector <3 x float> %78, <3 x float> poison, <3 x i32> zeroinitializer
  %80 = shufflevector <4 x float> %42, <4 x float> poison, <3 x i32> <i32 0, i32 1, i32 2>
  %81 = fdiv fast <3 x float> %80, %79
  %82 = insertelement <3 x float> poison, float %3, i64 0
  %83 = shufflevector <3 x float> %82, <3 x float> poison, <3 x i32> zeroinitializer
  %84 = tail call fast <3 x float> @air.fast_clamp.v3f32(<3 x float> %81, <3 x float> splat (float -7.500000e-01), <3 x float> %83) #17
  %85 = shufflevector <4 x float> %42, <4 x float> undef, <3 x i32> <i32 3, i32 3, i32 3>
  %86 = fmul fast <3 x float> %84, %85
  %87 = shufflevector <3 x float> %86, <3 x float> poison, <4 x i32> <i32 0, i32 1, i32 2, i32 poison>
  %88 = shufflevector <4 x float> %87, <4 x float> %42, <4 x i32> <i32 0, i32 1, i32 2, i32 7>
  br label %89

89:                                               ; preds = %75, %68, %5
  %90 = phi <4 x float> [ %74, %68 ], [ %88, %75 ], [ %42, %5 ]
  %91 = extractelement <4 x float> %90, i64 3
  %92 = fsub fast float 1.000000e+00, %91
  %93 = insertelement <4 x float> poison, float %92, i64 0
  %94 = shufflevector <4 x float> %93, <4 x float> poison, <4 x i32> zeroinitializer
  %95 = fmul fast <4 x float> %94, %1
  %96 = fadd fast <4 x float> %95, %90
  ret <4 x float> %96
}

; Function Attrs: inlinehint mustprogress nounwind
define internal fastcc <4 x float> @_ZN10UberShaderIffE24sdf_diffuse_kf_highlightEDv4_fS1_S1_S1_S1_S1_S1_S1_(<4 x float> noundef %0, <4 x float> noundef %1, <4 x float> noundef %2, <4 x float> noundef %3, <4 x float> noundef %4, <4 x float> noundef %5, <4 x float> noundef %6, <4 x float> noundef %7) unnamed_addr #6 align 2 {
  %9 = extractelement <4 x float> %1, i64 0
  %10 = extractelement <4 x float> %1, i64 1
  %11 = shufflevector <4 x float> %1, <4 x float> %2, <2 x i32> <i32 3, i32 4>
  %12 = extractelement <4 x float> %2, i64 1
  %13 = extractelement <4 x float> %2, i64 2
  %14 = extractelement <4 x float> %3, i64 2
  %15 = extractelement <4 x float> %3, i64 3
  %16 = extractelement <4 x float> %4, i64 0
  %17 = extractelement <4 x float> %4, i64 1
  %18 = extractelement <4 x float> %4, i64 3
  %19 = extractelement <4 x float> %5, i64 0
  %20 = extractelement <4 x float> %0, i64 0
  %21 = fadd fast float %15, %20
  %22 = fneg fast float %21
  %23 = shufflevector <4 x float> %0, <4 x float> poison, <2 x i32> <i32 1, i32 2>
  %24 = tail call fast float @air.dot.v2f32(<2 x float> %23, <2 x float> %23) #17
  %25 = tail call fast float @air.fast_sqrt.f32(float %24) #17
  %26 = fdiv fast float 1.000000e+00, %25
  %27 = insertelement <2 x float> poison, float %26, i64 0
  %28 = shufflevector <2 x float> %27, <2 x float> poison, <2 x i32> zeroinitializer
  %29 = fmul fast <2 x float> %28, %23
  %30 = extractelement <4 x float> %5, i64 2
  %31 = tail call i1 @air.convert.u.i1.f.f32(float %30) #17
  %32 = select i1 %31, float %26, float 1.000000e+00
  %33 = fmul fast float %32, %22
  %34 = tail call fast float @air.dot.v2f32(<2 x float> %11, <2 x float> %29) #17
  %35 = fneg fast float %34
  %36 = fdiv fast float %33, %9
  %37 = tail call fast float @air.fast_saturate.f32(float %36) #17
  %38 = fsub fast float 1.000000e+00, %37
  %39 = fcmp fast olt float %37, 1.000000e+00
  %40 = select fast i1 %39, float 1.000000e+00, float 0.000000e+00
  %41 = tail call fast float @air.mix.f32(float %40, float %38, float %14) #17
  %42 = tail call fast float @air.fwidth.f32(float %33) #21
  %43 = tail call fast float @air.fast_fmax.f32(float %42, float 0x3F1A36E2E0000000) #17
  %44 = fdiv fast float %33, %43
  %45 = fadd fast float %44, 5.000000e-01
  %46 = tail call fast float @air.fast_saturate.f32(float %45) #17
  %47 = fmul fast float %46, %41
  %48 = fsub fast float %9, %33
  %49 = fdiv fast float %48, %43
  %50 = fadd fast float %49, 5.000000e-01
  %51 = tail call fast float @air.fast_saturate.f32(float %50) #17
  %52 = fmul fast float %47, %51
  %53 = fsub fast float %34, %10
  %54 = fsub fast float 1.000000e+00, %10
  %55 = tail call fast float @air.fast_fmax.f32(float %54, float 0x3EB0C6F7A0000000) #17
  %56 = fdiv fast float %53, %55
  %57 = tail call fast float @air.fast_saturate.f32(float %56) #17
  %58 = fmul fast float %52, %57
  %59 = fdiv fast float %33, %12
  %60 = tail call fast float @air.fast_saturate.f32(float %59) #17
  %61 = fsub fast float 1.000000e+00, %60
  %62 = fcmp fast olt float %60, 1.000000e+00
  %63 = select fast i1 %62, float 1.000000e+00, float 0.000000e+00
  %64 = tail call fast float @air.mix.f32(float %63, float %61, float %14) #17
  %65 = tail call fast float @air.fwidth.f32(float %33) #21
  %66 = tail call fast float @air.fast_fmax.f32(float %65, float 0x3F1A36E2E0000000) #17
  %67 = fdiv fast float %33, %66
  %68 = fadd fast float %67, 5.000000e-01
  %69 = tail call fast float @air.fast_saturate.f32(float %68) #17
  %70 = fmul fast float %69, %64
  %71 = fsub fast float %12, %33
  %72 = fdiv fast float %71, %66
  %73 = fadd fast float %72, 5.000000e-01
  %74 = tail call fast float @air.fast_saturate.f32(float %73) #17
  %75 = fmul fast float %70, %74
  %76 = fsub fast float %35, %13
  %77 = fsub fast float 1.000000e+00, %13
  %78 = tail call fast float @air.fast_fmax.f32(float %77, float 0x3EB0C6F7A0000000) #17
  %79 = fdiv fast float %76, %78
  %80 = tail call fast float @air.fast_saturate.f32(float %79) #17
  %81 = fmul fast float %75, %80
  %82 = fdiv fast float %33, %16
  %83 = tail call fast float @air.fast_saturate.f32(float %82) #17
  %84 = fsub fast float 1.000000e+00, %83
  %85 = tail call fast float @air.fwidth.f32(float %33) #21
  %86 = tail call fast float @air.fast_fmax.f32(float %85, float 0x3F1A36E2E0000000) #17
  %87 = fdiv fast float %33, %86
  %88 = fadd fast float %87, 5.000000e-01
  %89 = tail call fast float @air.fast_saturate.f32(float %88) #17
  %90 = fmul fast float %89, %84
  %91 = fsub fast float %16, %33
  %92 = fdiv fast float %91, %86
  %93 = fadd fast float %92, 5.000000e-01
  %94 = tail call fast float @air.fast_saturate.f32(float %93) #17
  %95 = fmul fast float %90, %94
  %96 = fsub fast float %34, %17
  %97 = fsub fast float 1.000000e+00, %17
  %98 = tail call fast float @air.fast_fmax.f32(float %97, float 0x3EB0C6F7A0000000) #17
  %99 = fdiv fast float %96, %98
  %100 = tail call fast float @air.fast_saturate.f32(float %99) #17
  %101 = fmul fast float %95, %100
  %102 = fdiv fast float %33, %18
  %103 = tail call fast float @air.fast_saturate.f32(float %102) #17
  %104 = fsub fast float 1.000000e+00, %103
  %105 = tail call fast float @air.fwidth.f32(float %33) #21
  %106 = tail call fast float @air.fast_fmax.f32(float %105, float 0x3F1A36E2E0000000) #17
  %107 = fdiv fast float %33, %106
  %108 = fadd fast float %107, 5.000000e-01
  %109 = tail call fast float @air.fast_saturate.f32(float %108) #17
  %110 = fmul fast float %109, %104
  %111 = fsub fast float %18, %33
  %112 = fdiv fast float %111, %106
  %113 = fadd fast float %112, 5.000000e-01
  %114 = tail call fast float @air.fast_saturate.f32(float %113) #17
  %115 = fmul fast float %110, %114
  %116 = fsub fast float %35, %19
  %117 = fsub fast float 1.000000e+00, %19
  %118 = tail call fast float @air.fast_fmax.f32(float %117, float 0x3EB0C6F7A0000000) #17
  %119 = fdiv fast float %116, %118
  %120 = tail call fast float @air.fast_saturate.f32(float %119) #17
  %121 = fmul fast float %115, %120
  %122 = fadd fast float %81, %58
  %123 = fadd fast float %122, %101
  %124 = fadd fast float %123, %121
  %125 = fcmp fast olt float %124, 0x3EB0C6F7A0000000
  %126 = fcmp fast olt float %33, -5.000000e+00
  %127 = select i1 %125, i1 true, i1 %126
  br i1 %127, label %128, label %129

128:                                              ; preds = %8
  tail call void @air.discard_fragment() #24
  br label %129

129:                                              ; preds = %128, %8
  %130 = extractelement <4 x float> %5, i64 1
  %131 = extractelement <4 x float> %4, i64 2
  %132 = extractelement <4 x float> %2, i64 3
  %133 = extractelement <4 x float> %1, i64 2
  %134 = fneg fast float %133
  %135 = fadd fast float %133, 1.000000e+00
  %136 = tail call fast float @air.fma.f32(float %134, float %58, float %135) #17
  %137 = tail call fast float @air.fast_fmax.f32(float %136, float 0x3EB0C6F7A0000000) #17
  %138 = fdiv fast float %58, %137
  %139 = fneg fast float %132
  %140 = fadd fast float %132, 1.000000e+00
  %141 = tail call fast float @air.fma.f32(float %139, float %81, float %140) #17
  %142 = tail call fast float @air.fast_fmax.f32(float %141, float 0x3EB0C6F7A0000000) #17
  %143 = fdiv fast float %81, %142
  %144 = fneg fast float %131
  %145 = fadd fast float %131, 1.000000e+00
  %146 = tail call fast float @air.fma.f32(float %144, float %101, float %145) #17
  %147 = tail call fast float @air.fast_fmax.f32(float %146, float 0x3EB0C6F7A0000000) #17
  %148 = fdiv fast float %101, %147
  %149 = fneg fast float %130
  %150 = fadd fast float %130, 1.000000e+00
  %151 = tail call fast float @air.fma.f32(float %149, float %121, float %150) #17
  %152 = tail call fast float @air.fast_fmax.f32(float %151, float 0x3EB0C6F7A0000000) #17
  %153 = fdiv fast float %121, %152
  %154 = fadd fast float %148, %138
  %155 = insertelement <4 x float> poison, float %154, i64 0
  %156 = shufflevector <4 x float> %155, <4 x float> poison, <4 x i32> zeroinitializer
  %157 = fmul fast <4 x float> %156, %6
  %158 = fadd fast float %153, %143
  %159 = insertelement <4 x float> poison, float %158, i64 0
  %160 = shufflevector <4 x float> %159, <4 x float> poison, <4 x i32> zeroinitializer
  %161 = fmul fast <4 x float> %160, %7
  %162 = fadd fast <4 x float> %161, %157
  ret <4 x float> %162
}

; Function Attrs: mustprogress nofree nosync nounwind willreturn memory(none)
declare float @air.fma.f32(float, float, float) local_unnamed_addr #1

; Function Attrs: convergent mustprogress nounwind willreturn
declare float @air.fwidth.f32(float) local_unnamed_addr #9

; Function Attrs: mustprogress nofree nosync nounwind willreturn memory(none)
declare i1 @air.convert.u.i1.f.f32(float) local_unnamed_addr #1

; Function Attrs: mustprogress nofree nosync nounwind willreturn memory(none)
declare float @air.fast_sqrt.f32(float) local_unnamed_addr #1

; Function Attrs: convergent inlinehint mustprogress nounwind
define internal fastcc <4 x float> @_ZN10UberShaderIffE22sdf_key_fill_highlightEDv4_fS1_S1_S1_S1_S1_S1_(<4 x float> noundef %0, <4 x float> noundef %1, <4 x float> noundef %2, <4 x float> noundef %3, <4 x float> noundef %4, <4 x float> noundef %5, <4 x float> noundef %6) unnamed_addr #6 align 2 {
  %8 = extractelement <4 x float> %1, i64 0
  %9 = extractelement <4 x float> %1, i64 1
  %10 = shufflevector <4 x float> %1, <4 x float> %2, <2 x i32> <i32 3, i32 4>
  %11 = extractelement <4 x float> %2, i64 1
  %12 = extractelement <4 x float> %2, i64 2
  %13 = shufflevector <4 x float> %3, <4 x float> undef, <2 x i32> <i32 0, i32 1>
  %14 = extractelement <4 x float> %3, i64 2
  %15 = extractelement <4 x float> %0, i64 0
  %16 = extractelement <4 x float> %3, i64 3
  %17 = fadd fast float %16, %15
  %18 = fneg fast float %17
  %19 = shufflevector <4 x float> %0, <4 x float> poison, <2 x i32> <i32 1, i32 2>
  %20 = tail call fast float @air.dot.v2f32(<2 x float> %19, <2 x float> %19) #17
  %21 = tail call fast float @air.fast_sqrt.f32(float %20) #17
  %22 = fdiv fast float 1.000000e+00, %21
  %23 = insertelement <2 x float> poison, float %22, i64 0
  %24 = shufflevector <2 x float> %23, <2 x float> poison, <2 x i32> zeroinitializer
  %25 = fmul fast <2 x float> %24, %19
  %26 = extractelement <4 x float> %4, i64 0
  %27 = tail call i1 @air.convert.u.i1.f.f32(float %26) #17
  %28 = select i1 %27, float %22, float 1.000000e+00
  %29 = fmul fast float %28, %18
  %30 = tail call fast float @air.dot.v2f32(<2 x float> %10, <2 x float> %25) #17
  %31 = fdiv fast float %29, %8
  %32 = tail call fast float @air.fast_saturate.f32(float %31) #17
  %33 = fsub fast float 1.000000e+00, %32
  %34 = fcmp fast olt float %32, 1.000000e+00
  %35 = select fast i1 %34, float 1.000000e+00, float 0.000000e+00
  %36 = tail call fast float @air.mix.f32(float %35, float %33, float %14) #17
  %37 = tail call fast float @air.fwidth.f32(float %29) #21
  %38 = tail call fast float @air.fast_fmax.f32(float %37, float 0x3F1A36E2E0000000) #17
  %39 = fdiv fast float %29, %38
  %40 = fadd fast float %39, 5.000000e-01
  %41 = tail call fast float @air.fast_saturate.f32(float %40) #17
  %42 = fmul fast float %41, %36
  %43 = fsub fast float %8, %29
  %44 = fdiv fast float %43, %38
  %45 = fadd fast float %44, 5.000000e-01
  %46 = tail call fast float @air.fast_saturate.f32(float %45) #17
  %47 = fmul fast float %42, %46
  %48 = fsub fast float %30, %9
  %49 = fsub fast float 1.000000e+00, %9
  %50 = tail call fast float @air.fast_fmax.f32(float %49, float 0x3EB0C6F7A0000000) #17
  %51 = fdiv fast float %48, %50
  %52 = tail call fast float @air.fast_saturate.f32(float %51) #17
  %53 = fmul fast float %47, %52
  %54 = fcmp fast olt float %29, -5.000000e+00
  %55 = select i1 %54, float 0.000000e+00, float %53
  %56 = tail call fast float @air.dot.v2f32(<2 x float> %13, <2 x float> %25) #17
  %57 = fdiv fast float %29, %11
  %58 = tail call fast float @air.fast_saturate.f32(float %57) #17
  %59 = fsub fast float 1.000000e+00, %58
  %60 = fcmp fast olt float %58, 1.000000e+00
  %61 = select fast i1 %60, float 1.000000e+00, float 0.000000e+00
  %62 = tail call fast float @air.mix.f32(float %61, float %59, float %14) #17
  %63 = tail call fast float @air.fwidth.f32(float %29) #21
  %64 = tail call fast float @air.fast_fmax.f32(float %63, float 0x3F1A36E2E0000000) #17
  %65 = fdiv fast float %29, %64
  %66 = fadd fast float %65, 5.000000e-01
  %67 = tail call fast float @air.fast_saturate.f32(float %66) #17
  %68 = fmul fast float %67, %62
  %69 = fsub fast float %11, %29
  %70 = fdiv fast float %69, %64
  %71 = fadd fast float %70, 5.000000e-01
  %72 = tail call fast float @air.fast_saturate.f32(float %71) #17
  %73 = fmul fast float %68, %72
  %74 = fsub fast float %56, %12
  %75 = fsub fast float 1.000000e+00, %12
  %76 = tail call fast float @air.fast_fmax.f32(float %75, float 0x3EB0C6F7A0000000) #17
  %77 = fdiv fast float %74, %76
  %78 = tail call fast float @air.fast_saturate.f32(float %77) #17
  %79 = fmul fast float %73, %78
  %80 = select i1 %54, float 0.000000e+00, float %79
  %81 = fadd fast float %80, %55
  %82 = fcmp fast olt float %81, 0x3EB0C6F7A0000000
  br i1 %82, label %83, label %84

83:                                               ; preds = %7
  tail call void @air.discard_fragment() #24
  br label %84

84:                                               ; preds = %83, %7
  %85 = extractelement <4 x float> %2, i64 3
  %86 = extractelement <4 x float> %1, i64 2
  %87 = fsub fast float 1.000000e+00, %55
  %88 = fmul fast float %87, %86
  %89 = fadd fast float %88, 1.000000e+00
  %90 = tail call fast float @air.fast_fmax.f32(float %89, float 0x3EB0C6F7A0000000) #17
  %91 = fdiv fast float %55, %90
  %92 = fsub fast float 1.000000e+00, %80
  %93 = fmul fast float %92, %85
  %94 = fadd fast float %93, 1.000000e+00
  %95 = tail call fast float @air.fast_fmax.f32(float %94, float 0x3EB0C6F7A0000000) #17
  %96 = fdiv fast float %80, %95
  %97 = insertelement <4 x float> poison, float %91, i64 0
  %98 = shufflevector <4 x float> %97, <4 x float> poison, <4 x i32> zeroinitializer
  %99 = fmul fast <4 x float> %98, %5
  %100 = insertelement <4 x float> poison, float %96, i64 0
  %101 = shufflevector <4 x float> %100, <4 x float> poison, <4 x i32> zeroinitializer
  %102 = fmul fast <4 x float> %101, %6
  %103 = fadd fast <4 x float> %102, %99
  ret <4 x float> %103
}

; Function Attrs: convergent inlinehint mustprogress nounwind
define internal fastcc <4 x float> @_ZN10UberShaderIffE22sdf_glass_displacementEDv4_fS1_S1_(<4 x float> noundef %0, <4 x float> noundef %1, <4 x float> noundef %2) unnamed_addr #6 align 2 {
  %4 = extractelement <4 x float> %0, i64 0
  %5 = extractelement <4 x float> %1, i64 2
  %6 = fadd fast float %5, %4
  %7 = fneg fast float %6
  %8 = extractelement <4 x float> %1, i64 3
  %9 = fsub fast float %7, %8
  %10 = tail call fast float @air.fwidth.f32(float %9) #21
  %11 = tail call fast float @air.fast_fmax.f32(float %10, float 0x3F1A36E2E0000000) #17
  %12 = fdiv fast float %9, %11
  %13 = fadd fast float %12, 5.000000e-01
  %14 = tail call fast float @air.fast_saturate.f32(float %13) #17
  %15 = extractelement <4 x float> %0, i64 3
  %16 = fmul fast float %14, %15
  %17 = fcmp fast olt float %9, -5.000000e+00
  %18 = select i1 %17, float 0.000000e+00, float %16
  %19 = extractelement <4 x float> %1, i64 0
  %20 = fdiv fast float %7, %19
  %21 = tail call fast float @air.fast_saturate.f32(float %20) #17
  %22 = fcmp fast olt float %21, 1.000000e+00
  %23 = zext i1 %22 to i32
  %24 = tail call fast float @air.convert.f.f32.s.i32(i32 %23) #17
  %25 = fmul fast float %24, 0x3FD2BEDFA0000000
  %26 = fsub fast float 1.000000e+00, %25
  %27 = fsub fast float 1.000000e+00, %21
  %28 = fmul fast float %27, %27
  %29 = fsub fast float 1.000000e+00, %28
  %30 = tail call fast float @air.fast_sqrt.f32(float %29) #17
  %31 = extractelement <4 x float> %1, i64 1
  %32 = tail call fast float @air.mix.f32(float %26, float %30, float %31) #17
  %33 = shufflevector <4 x float> %0, <4 x float> poison, <2 x i32> <i32 1, i32 2>
  %34 = extractelement <4 x float> %2, i64 0
  %35 = insertelement <2 x float> undef, float %34, i64 0
  %36 = extractelement <4 x float> %2, i64 1
  %37 = fneg fast float %36
  %38 = insertelement <2 x float> %35, float %37, i64 1
  %39 = tail call fast float @air.dot.v2f32(<2 x float> %33, <2 x float> %38) #17
  %40 = insertelement <2 x float> undef, float %39, i64 0
  %41 = shufflevector <4 x float> %2, <4 x float> poison, <2 x i32> <i32 1, i32 0>
  %42 = tail call fast float @air.dot.v2f32(<2 x float> %33, <2 x float> %41) #17
  %43 = insertelement <2 x float> %40, float %42, i64 1
  %44 = fsub fast float 1.000000e+00, %32
  %45 = insertelement <2 x float> poison, float %44, i64 0
  %46 = shufflevector <2 x float> %45, <2 x float> poison, <2 x i32> zeroinitializer
  %47 = fmul fast <2 x float> %43, %46
  %48 = fadd fast float %6, %19
  %49 = fdiv fast float %48, %11
  %50 = fadd fast float %49, 5.000000e-01
  %51 = tail call fast float @air.fast_saturate.f32(float %50) #17
  %52 = insertelement <2 x float> poison, float %51, i64 0
  %53 = shufflevector <2 x float> %52, <2 x float> poison, <2 x i32> zeroinitializer
  %54 = fmul fast <2 x float> %47, %53
  %55 = extractelement <2 x float> %54, i64 0
  %56 = extractelement <2 x float> %54, i64 1
  %57 = insertelement <4 x float> <float poison, float poison, float poison, float 1.000000e+00>, float %55, i64 0
  %58 = insertelement <4 x float> %57, float %56, i64 1
  %59 = insertelement <4 x float> %58, float %18, i64 2
  ret <4 x float> %59
}

; Function Attrs: mustprogress nofree nosync nounwind willreturn memory(none)
declare float @air.convert.f.f32.s.i32(i32) local_unnamed_addr #1

; Function Attrs: convergent inlinehint mustprogress nounwind
define internal fastcc <4 x float> @_ZN10UberShaderIffE19sdf_glass_highlightEDv4_fS1_S1_S1_(<4 x float> noundef %0, <4 x float> noundef %1, <4 x float> noundef %2, <4 x float> noundef %3) unnamed_addr #6 align 2 {
  %5 = extractelement <4 x float> %1, i64 0
  %6 = extractelement <4 x float> %1, i64 1
  %7 = extractelement <4 x float> %2, i64 1
  %8 = shufflevector <4 x float> %1, <4 x float> poison, <2 x i32> <i32 2, i32 3>
  %9 = extractelement <4 x float> %0, i64 0
  %10 = extractelement <4 x float> %2, i64 2
  %11 = fadd fast float %10, %9
  %12 = fneg fast float %11
  %13 = shufflevector <4 x float> %0, <4 x float> poison, <2 x i32> <i32 1, i32 2>
  %14 = tail call fast float @air.dot.v2f32(<2 x float> %13, <2 x float> %13) #17
  %15 = tail call fast float @air.fast_sqrt.f32(float %14) #17
  %16 = fdiv fast float 1.000000e+00, %15
  %17 = insertelement <2 x float> poison, float %16, i64 0
  %18 = shufflevector <2 x float> %17, <2 x float> poison, <2 x i32> zeroinitializer
  %19 = fmul fast <2 x float> %18, %13
  %20 = fmul fast float %16, %12
  %21 = tail call fast float @air.dot.v2f32(<2 x float> %8, <2 x float> %19) #17
  %22 = fdiv fast float %20, %5
  %23 = tail call fast float @air.fast_saturate.f32(float %22) #17
  %24 = fsub fast float 1.000000e+00, %23
  %25 = fcmp fast olt float %23, 1.000000e+00
  %26 = select fast i1 %25, float 1.000000e+00, float 0.000000e+00
  %27 = tail call fast float @air.mix.f32(float %26, float %24, float %7) #17
  %28 = tail call fast float @air.fwidth.f32(float %20) #21
  %29 = tail call fast float @air.fast_fmax.f32(float %28, float 0x3F1A36E2E0000000) #17
  %30 = fdiv fast float %20, %29
  %31 = fadd fast float %30, 5.000000e-01
  %32 = tail call fast float @air.fast_saturate.f32(float %31) #17
  %33 = fmul fast float %32, %27
  %34 = fsub fast float %5, %20
  %35 = fdiv fast float %34, %29
  %36 = fadd fast float %35, 5.000000e-01
  %37 = tail call fast float @air.fast_saturate.f32(float %36) #17
  %38 = fmul fast float %33, %37
  %39 = fsub fast float %21, %6
  %40 = fsub fast float 1.000000e+00, %6
  %41 = tail call fast float @air.fast_fmax.f32(float %40, float 0x3EB0C6F7A0000000) #17
  %42 = fdiv fast float %39, %41
  %43 = tail call fast float @air.fast_saturate.f32(float %42) #17
  %44 = fmul fast float %38, %43
  %45 = fcmp fast olt float %20, -5.000000e+00
  %46 = select i1 %45, float 0.000000e+00, float %44
  %47 = fcmp fast olt float %46, 0x3EB0C6F7A0000000
  br i1 %47, label %48, label %49

48:                                               ; preds = %4
  tail call void @air.discard_fragment() #24
  br label %49

49:                                               ; preds = %48, %4
  %50 = extractelement <4 x float> %2, i64 0
  %51 = fsub fast float 1.000000e+00, %46
  %52 = fmul fast float %51, %50
  %53 = fadd fast float %52, 1.000000e+00
  %54 = tail call fast float @air.fast_fmax.f32(float %53, float 0x3EB0C6F7A0000000) #17
  %55 = fdiv fast float %46, %54
  %56 = insertelement <4 x float> poison, float %55, i64 0
  %57 = shufflevector <4 x float> %56, <4 x float> poison, <4 x i32> zeroinitializer
  %58 = fmul fast <4 x float> %57, %3
  ret <4 x float> %58
}

; Function Attrs: convergent inlinehint mustprogress nounwind
