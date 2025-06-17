import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';

import 'user_resources_dialog.dart';

class AppBarResourceWidget extends ConsumerStatefulWidget {
  final bool isVertical;

  const AppBarResourceWidget({
    super.key,
    this.isVertical = false,
  });

  @override
  ConsumerState<AppBarResourceWidget> createState() =>
      _AppBarResourceWidgetState();
}

class _AppBarResourceWidgetState extends ConsumerState<AppBarResourceWidget>
    with TickerProviderStateMixin {
  // Animation controllers for coins
  late AnimationController _coinsController;
  late Animation<int> _coinsAnimation;
  int? _latestCoinsValue;

  // Animation controllers for energy
  late AnimationController _energyController;
  late Animation<int> _energyAnimation;
  int? _latestEnergyValue;
  int? _latestMaxEnergyValue;

  @override
  void initState() {
    super.initState();

    // Initialize coins animation controller
    _coinsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize energy animation controller
    _energyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Initialize animations with current values
    // Safely read initial coins, providing a default of 0 if currentUser or coins is null
    final initialCoins = ref.read(authProvider).currentUser.coins;
    _latestCoinsValue = initialCoins;
    _coinsAnimation = IntTween(
      begin: initialCoins,
      end: initialCoins,
    ).animate(CurvedAnimation(
      parent: _coinsController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
    ));

    // For energy, assuming you have current and max values
    // Replace this with actual energy values from your provider if different
    const initialEnergy = 8;
    const maxEnergy = 8;
    _latestEnergyValue = initialEnergy;
    _latestMaxEnergyValue = maxEnergy;
    _energyAnimation = IntTween(
      begin: initialEnergy,
      end: initialEnergy,
    ).animate(CurvedAnimation(
      parent: _energyController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
    ));
  }

  @override
  void dispose() {
    _coinsController.dispose();
    _energyController.dispose();
    super.dispose();
  }

  // Starts the coins animation from the current value to the new end value
  void _startCoinsAnimation(int end) {
    _coinsController.stop();
    final begin = _latestCoinsValue ?? end;
    _latestCoinsValue = end;
    setState(() {
      _coinsAnimation = IntTween(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: _coinsController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
      ));
    });
    _coinsController.forward(from: 0.0);
  }

  // Starts the energy animation from the current value to the new end value
  void _startEnergyAnimation(int end, int maxEnergy) {
    _energyController.stop();
    final begin = _latestEnergyValue ?? end;
    _latestEnergyValue = end;
    _latestMaxEnergyValue = maxEnergy;
    setState(() {
      _energyAnimation = IntTween(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(
        parent: _energyController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOutQuad),
      ));
    });
    _energyController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;
    final currentCoins = currentUser.coins;

    // Trigger coins animation if value has changed
    if (_latestCoinsValue != currentCoins) {
      _startCoinsAnimation(currentCoins);
    }

    // Example energy values; replace with your actual energy data
    const currentEnergy = 8;
    const maxEnergy = 8;

    // Trigger energy animation if values have changed
    if (_latestEnergyValue != currentEnergy ||
        _latestMaxEnergyValue != maxEnergy) {
      _startEnergyAnimation(currentEnergy, maxEnergy);
    }

    return GestureDetector(
      onTap: () =>
          UserResourcesDialog.show(context), // Tapping opens the dialog
      child: Container(
        height: widget.isVertical ? null : kToolbarHeight - 16,
        padding: widget.isVertical
            ? EdgeInsets.symmetric(vertical: calcHeight(8))
            : EdgeInsets.symmetric(horizontal: calcWidth(8)),
        child: widget.isVertical
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedCoins(),
                  SizedBox(height: calcHeight(10)),
                  _buildAnimatedEnergy(),
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedCoins(),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: calcHeight(8)),
                    child: VerticalDivider(
                      color: Colors.white.withValues(alpha: 0.3),
                      thickness: 1,
                      width: calcWidth(15),
                    ),
                  ),
                  _buildAnimatedEnergy(),
                ],
              ),
      ),
    );
  }

  // Builds the animated coins display (icon and text horizontally aligned)
  Widget _buildAnimatedCoins() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          Strings.coinsIcon,
          height: calcHeight(30),
          width: calcWidth(30),
        ),
        AnimatedBuilder(
          animation: _coinsController,
          builder: (context, child) {
            final displayValue = _coinsController.isCompleted
                ? _latestCoinsValue!
                : _coinsAnimation.value;
            return Text(
              displayValue.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedEnergy() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          Strings.energyIcon,
          height: calcHeight(30),
          width: calcWidth(30),
        ),
        AnimatedBuilder(
          animation: _energyController,
          builder: (context, child) {
            final displayValue = _energyController.isCompleted
                ? _latestEnergyValue!
                : _energyAnimation.value;
            final maxValue = _latestMaxEnergyValue ?? 8;
            return Text(
              "$displayValue/$maxValue",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          },
        ),
      ],
    );
  }
}
