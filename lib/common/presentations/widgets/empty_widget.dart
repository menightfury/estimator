import 'package:estimator/common_libs.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.iconSize = 54.0, this.color, this.label, this.onPressed});

  final double iconSize;
  final Widget? label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = this.color ?? theme.primaryColor;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.dashboard_rounded, size: iconSize, color: color),

            if (label != null) ...[
              const Gap(16.0),
              DefaultTextStyle(
                style: theme.textTheme.labelMedium!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                child: label!,
              ),
            ],

            if (onPressed != null) ...[
              const Gap(16.0),
              ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add user'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
