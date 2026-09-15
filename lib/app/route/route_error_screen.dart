import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/constants/constants.dart';
import 'package:learn_english_app/base/extensions/extensions.dart';

import 'route_constants.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withAlpha(0.1.toAlpha()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              SizedBox(height: AppDimensions.paddingXL),

               Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingM),

               Text(
                'The page you are looking for doesn\'t exist or has been moved.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(0.7.toAlpha()),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingXL),

               Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleGoBack(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppDimensions.paddingM),

                   Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleGoHome(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Go Home',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppDimensions.paddingXL),

               Text(
                'If you believe this is an error, please contact support.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(0.5.toAlpha()),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // If can't go back, go to home
      _handleGoHome(context);
    }
  }

  void _handleGoHome(BuildContext context) {
    // context.go(RouteConstants.home);
  }
}

class CustomRouteErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const CustomRouteErrorScreen({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An unexpected error occurred.',
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Custom Icon or Default Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withAlpha(0.1.toAlpha()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline,
                  size: 60,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),

              SizedBox(height: AppDimensions.paddingXL),

              // Custom Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingM),

              // Custom Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha(0.7.toAlpha()),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppDimensions.paddingXL),

              // Custom Action Button (if provided)
              if (actionLabel != null && onAction != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      actionLabel!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppDimensions.paddingL),
              ],

              // Default Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Go Back Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleGoBack(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child: Text(
                        'Go Back',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppDimensions.paddingM),

                  // Go Home Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleGoHome(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Go Home',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleGoBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // If can't go back, go to home
      _handleGoHome(context);
    }
  }

  void _handleGoHome(BuildContext context) {
    // context.go(RouteConstants.home);
  }
}
