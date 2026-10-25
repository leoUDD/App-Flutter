import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Cómo se le explica un error al usuario.
class ErrorInfo {
  final String title;
  final String hint;
  final String code;
  final IconData icon;

  const ErrorInfo({
    required this.title,
    required this.hint,
    required this.code,
    required this.icon,
  });
}

/// Traduce un error técnico (casi siempre de `dio`) a un mensaje comprensible.
ErrorInfo describeError(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ErrorInfo(
          title: 'Sin conexión',
          hint: 'Revisa tu conexión a internet e inténtalo de nuevo.',
          code: 'tiempo de espera agotado',
          icon: Icons.wifi_off,
        );
      case DioExceptionType.connectionError:
        return const ErrorInfo(
          title: 'Sin conexión',
          hint: 'Revisa tu conexión a internet e inténtalo de nuevo.',
          code: 'no hay conexión a internet',
          icon: Icons.wifi_off,
        );
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return ErrorInfo(
          title: 'El servidor no respondió bien',
          hint: 'Inténtalo de nuevo en unos minutos.',
          code: 'respuesta ${status ?? 'desconocida'}',
          icon: Icons.cloud_off,
        );
      default:
        return ErrorInfo(
          title: 'No se pudo conectar',
          hint: 'Inténtalo de nuevo en unos minutos.',
          code: error.type.name,
          icon: Icons.cloud_off,
        );
    }
  }
  return const ErrorInfo(
    title: 'Algo salió mal',
    hint: 'Inténtalo de nuevo.',
    code: 'error inesperado',
    icon: Icons.error_outline,
  );
}
