// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Cores Primárias do Tema (Roxo e Azul)
  static const Color purple500 = Color(0xFF9827E3);
  static const Color purple200 = Color(0xFFB672E3);
  static const Color purple700 = Color(0xFF6E1DB1);

  static const Color blue500 = Color(0xFF2730E3);
  static const Color blue200 = Color(0xFF7981E3);
  static const Color blue700 = Color(0xFF1C20C4);

  // Cores padrões do background app
  static const Color primaryDefaultColor = Color(0xFF341442);
  static const Color middleDefaultColor = Color(0xFF272251);
  static const Color lastDefaultColor = Color(0xFF142F59);

  // Fundo de Card de Edição
  static const Color bgCardEditColor = Color(0xFFEBEBEB);

  // Plano Básico
  static const Color planBasicoNormalBg = Color(0xFFF3E5F5);
  static const Color planBasicoNormalBorder = purple500;
  static const Color planBasicoCheckedBg = purple500;
  static const Color planBasicoCheckedBorder = purple700;

  // Plano Intermediário
  static const Color planIntermediarioNormalBg = Color(0xFFE1BEE7);
  static const Color planIntermediarioNormalBorder = purple700;
  static const Color planIntermediarioCheckedBg = purple700;
  static const Color planIntermediarioCheckedBorder = Color(
    0xFF5A007D,
  ); // Roxo ainda mais escuro

  // Plano Premium
  static const Color planPremiumNormalBg = Color(0xFFCE93D8);
  static const Color planPremiumNormalBorder = purple700;
  static const Color planPremiumCheckedBg =
      primaryDefaultColor; // Roxo bem escuro do tema
  static const Color planPremiumCheckedBorder = Color(
    0xFF2A0A33,
  ); // Borda profunda

  static const Color planRadioTextColorNormal = white; // Texto branco (do XML)
  static const Color planRadioTextColorChecked =
      purple700; // Texto purple_700 (do XML)

  // Cores de Componentes de Formulário
  static const Color textEditColor = Color(0xFF142F59);
  static const Color hintEditColor = Color(0xFF6E1DB1);
  static const Color drawableColor = Color(0xFF6E1DB1);
  static const Color progressbarDefaultColor = Color(0xFF30F4FD);

  // Background de EditText e Botão
  static const Color editBackgroundDefaultColor = Color(0xFFFFFFFF);
  static const Color editBorderDefaultColor = Color(0xFF5197F7);
  static const Color buttonDefaultColor = Color(0xFF5197F7);

  // Cores Neutras e de Fundo
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF2A2A47);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Cores de Texto
  static const Color textPrimaryDark = white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textPrimaryLight = darkBackground;
  static const Color textSecondaryLight = Color(0xFF555555);

  // Cores de Status e Ação
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF8BC34A);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color pending = Color(0xFFFF9800);
  static const Color paid = success;
  static const Color overdue = error;

  // Cores para Gradientes de Botões e Cards
  static const Color gradientStart = purple500;
  static const Color gradientEnd = blue500;
  static const Color gradientStartAlt = purple200;
  static const Color gradientEndAlt = blue200;

  // 🚨 NOVO: Gradiente de Contraste para destaque de fundo (Laranja/Amarelo)
  static const Color gradientContrastStart = warning; // Amarelo vibrante
  static const Color gradientContrastMid = pending; // Laranja
  static const Color gradientContrastEnd = lightBackground; // Fundo claro

  // Cores de Ícones
  static const Color iconActiveDark = white;
  static const Color iconInactiveDark = Color(0xFF888888);
  static const Color iconActiveLight = darkBackground;
  static const Color iconInactiveLight = Color(0xFFAAAAAA);

  // Primary palette (elegant violet + pastel)
  static const Color primary = Color(0xFF5B2E8A); // deep violet
  static const Color primaryVariant = Color(0xFF7E4AB3); // lighter violet
  static const Color accent = Color(0xFF8FD3C7); // pastel teal
  static const Color background = Color(0xFFF7F6FB); // off-white lavender
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF6B6B70);
  static const Color danger = Color(0xFFE55353);
  static const double borderRadius = 14.0;
}
