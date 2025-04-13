import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';
import 'package:trivia/data/providers/user_provider.dart';
import 'user_resources_dialog.dart';

class AppBarResourceWidget extends ConsumerStatefulWidget {
  const AppBarResourceWidget({super.key});

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
    // Replace this with actual energy values from your provider
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

  void _startCoinsAnimation(int end) {
    // Stop any ongoing animation
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
    // Reset and start the animation
    _coinsController.forward(from: 0.0);
  }

  void _startEnergyAnimation(int end, int maxEnergy) {
    // Stop any ongoing animation
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
    // Reset and start the animation
    _energyController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).currentUser;
    final currentCoins = currentUser.coins;

    // Start animation if coins value changed
    if (_latestCoinsValue != currentCoins) {
      _startCoinsAnimation(currentCoins);
    }

    // For energy, replace with your actual energy data
    // This is just an example assuming energy is 8/8
    const currentEnergy = 8;
    const maxEnergy = 8;

    // Start animation if energy values changed
    if (_latestEnergyValue != currentEnergy ||
        _latestMaxEnergyValue != maxEnergy) {
      _startEnergyAnimation(currentEnergy, maxEnergy);
    }

    return GestureDetector(
      onTap: () => UserResourcesDialog.show(context),
      child: Container(
        height: kToolbarHeight - 16,
        padding: EdgeInsets.symmetric(horizontal: calcWidth(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coins section with animation
            _buildAnimatedCoins(),

            Padding(
              padding: EdgeInsets.symmetric(vertical: calcHeight(8)),
              child: VerticalDivider(
                color: Colors.white.withValues(alpha: 0.3),
                thickness: 1,
                width: calcWidth(15),
              ),
            ),

            // Energy section with animation
            _buildAnimatedEnergy(),
          ],
        ),
      ),
    );
  }

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
