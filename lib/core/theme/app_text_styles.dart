import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static final TextStyle headline = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimaryLight,
  );

  static final TextStyle subtitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondaryLight,
  );

  static final TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.textPrimaryLight,
  );

  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.textSecondaryLight,
  );
}
