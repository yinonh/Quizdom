import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Quizdom/core/utils/size_config.dart';

import 'defaults.dart';
import 'fluttermoji_assets/fluttermojimodel.dart';
import 'fluttermoji_provider.dart';
import 'fluttermoji_theme_data.dart';

class FluttermojiCustomizer extends StatefulWidget {
  FluttermojiCustomizer({
    Key? key,
    this.scaffoldHeight,
    this.scaffoldWidth,
    FluttermojiThemeData? theme,
    List<String>? attributeTitles,
    List<String>? attributeIcons,
    this.autosave = true,
  })  : assert(
          attributeTitles == null || attributeTitles.length == attributesCount,
          "List of Attribute Titles must be of length $attributesCount.\n"
          " You need to provide titles for all attributes",
        ),
        assert(
          attributeIcons == null || attributeIcons.length == attributesCount,
          "List of Attribute Icon paths must be of length $attributesCount.\n"
          " You need to provide icon paths for all attributes",
        ),
        this.theme = theme ?? FluttermojiThemeData.standard,
        this.attributeTitles = attributeTitles ?? defaultAttributeTitles,
        this.attributeIcons = attributeIcons ?? defaultAttributeIcons,
        super(key: key);

  final double? scaffoldHeight;
  final double? scaffoldWidth;
  final FluttermojiThemeData theme;
  final List<String> attributeTitles;
  final List<String> attributeIcons;
  final bool autosave;

  static const int attributesCount = 11;

  @override
  _FluttermojiCustomizerState createState() => _FluttermojiCustomizerState();
}

class _FluttermojiCustomizerState extends State<FluttermojiCustomizer>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final attributesCount = 11;
  var heightFactor = 0.4, widthFactor = 0.95;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: attributesCount, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  void onTapOption(
      int index, int? currentIndex, AttributeItem attribute, WidgetRef ref) {
    if (index != currentIndex) {
      ref
          .read(fluttermojiNotifierProvider.notifier)
          .setSelectedOption(attribute.key!, index);
      if (widget.autosave) {
        ref.read(fluttermojiNotifierProvider.notifier).setFluttermoji();
      }
    }
  }

  void onArrowTap(bool isLeft) {
    int _currentIndex = tabController.index;
    if (isLeft) {
      tabController
          .animateTo(_currentIndex > 0 ? _currentIndex - 1 : _currentIndex);
    } else {
      tabController.animateTo(_currentIndex < attributesCount - 1
          ? _currentIndex + 1
          : _currentIndex);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SizedBox(
      height: widget.scaffoldHeight ?? (size.height * heightFactor),
      width: widget.scaffoldWidth ?? size.width,
      child: Consumer(
        builder: (context, ref, _) {
          final fluttermojiState = ref.watch(fluttermojiNotifierProvider);

          return fluttermojiState.when(
            data: (data) {
              return body(
                attributes: List<AttributeItem>.generate(
                  attributesCount,
                  (index) => AttributeItem(
                    iconAsset: widget.attributeIcons[index],
                    title: widget.attributeTitles[index],
                    key: attributeKeys[index],
                  ),
                  growable: false,
                ),
                state: data,
                ref: ref,
              );
            },
            loading: () => const Center(child: CupertinoActivityIndicator()),
            error: (err, stack) {
              throw (err);
            },
          );
        },
      ),
    );
  }

  Container bottomNavBar(List<Widget> navbarWidgets) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.primaryBgColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, -1),
            blurRadius: 4.0,
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        isScrollable: true,
        labelPadding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        indicatorColor: widget.theme.selectedIconColor,
        indicatorPadding: const EdgeInsets.all(2),
        tabs: navbarWidgets,
      ),
    );
  }

  AppBar appbar(List<AttributeItem> attributes) {
    return AppBar(
      centerTitle: true,
      elevation: 2,
      backgroundColor: widget.theme.primaryBgColor,
      automaticallyImplyLeading: false,
      title: Text(
        attributes[tabController.index].title,
        style: widget.theme.labelTextStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      leading: arrowButton(true),
      actions: [
        arrowButton(false),
      ],
    );
  }

  Widget arrowButton(bool isLeft) {
    return Visibility(
      visible: isLeft
          ? tabController.index > 0
          : tabController.index < attributesCount - 1,
      child: IconButton(
        icon: Icon(
          isLeft
              ? Icons.arrow_back_ios_new_rounded
              : Icons.arrow_forward_ios_rounded,
          color: widget.theme.iconColor,
        ),
        onPressed: () => onArrowTap(isLeft),
      ),
    );
  }

  Widget body({
    required List<AttributeItem> attributes,
    required FluttermojiState state,
    required WidgetRef ref,
  }) {
    var size = MediaQuery.of(context).size;

    var attributeGrids = <Widget>[];
    var navbarWidgets = <Widget>[];

    for (var attributeIndex = 0;
        attributeIndex < attributes.length;
        attributeIndex++) {
      var attribute = attributes[attributeIndex];
      final selectedIndex = state.selectedOptions[attribute.key] ?? 0;
      var attributeListLength =
          fluttermojiProperties[attribute.key!]!.property!.length;

      int gridCrossAxisCount;
      if (attributeListLength < 12)
        gridCrossAxisCount = 3;
      else if (attributeListLength < 9)
        gridCrossAxisCount = 2;
      else
        gridCrossAxisCount = 4;

      var _tileGrid = GridView.builder(
        physics: widget.theme.scrollPhysics,
        itemCount: attributeListLength,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridCrossAxisCount,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () => onTapOption(index, selectedIndex, attribute, ref),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: index == selectedIndex ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: index == selectedIndex
                  ? [
                      const BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 2.0,
                      ),
                    ]
                  : [],
            ),
            margin: widget.theme.tileMargin,
            padding: widget.theme.tilePadding,
            child: SvgPicture.string(
              ref
                  .read(fluttermojiNotifierProvider.notifier)
                  .getComponentSVG(attribute.key, index),
              height: 20,
              semanticsLabel: 'Your Fluttermoji',
              placeholderBuilder: (context) => const Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          ),
        ),
      );

      var bottomNavWidget = Padding(
          padding: EdgeInsets.symmetric(
              vertical: calcHeight(5), horizontal: calcWidth(10)),
          child: SvgPicture.asset(
            attribute.iconAsset!,
            height: widget.scaffoldHeight != null
                ? widget.scaffoldHeight! / heightFactor * 0.03
                : size.height * 0.03,
            colorFilter: ColorFilter.mode(
                attributeIndex == tabController.index
                    ? widget.theme.selectedIconColor
                    : widget.theme.unselectedIconColor,
                BlendMode.srcIn),
            semanticsLabel: attribute.title,
          ));

      attributeGrids.add(_tileGrid);
      navbarWidgets.add(bottomNavWidget);
    }

    return Container(
      decoration: widget.theme.boxDecoration,
      clipBehavior: Clip.hardEdge,
      child: DefaultTabController(
        length: attributeGrids.length,
        child: Scaffold(
          key: const ValueKey('FMojiCustomizer'),
          backgroundColor: widget.theme.secondaryBgColor,
          appBar: appbar(attributes),
          body: TabBarView(
            physics: widget.theme.scrollPhysics,
            controller: tabController,
            children: attributeGrids,
          ),
          bottomNavigationBar: bottomNavBar(navbarWidgets),
        ),
      ),
    );
  }
}
