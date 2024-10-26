import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'fluttermoji_assets/clothes/clothes.dart';
import 'fluttermoji_assets/face/eyebrow/eyebrow.dart';
import 'fluttermoji_assets/face/eyes/eyes.dart';
import 'fluttermoji_assets/face/mouth/mouth.dart';
import 'fluttermoji_assets/face/nose/nose.dart';
import 'fluttermoji_assets/fluttermojimodel.dart';
import 'fluttermoji_assets/skin.dart';
import 'fluttermoji_assets/style.dart';
import 'fluttermoji_assets/top/accessories/accessories.dart';
import 'fluttermoji_assets/top/facialHair/facialHair.dart';
import 'fluttermoji_assets/top/hairStyles/hairStyle.dart';

part 'fluttermoji_provider.freezed.dart';
part 'fluttermoji_provider.g.dart';

@freezed
class FluttermojiState with _$FluttermojiState {
  const factory FluttermojiState({
    required String fluttermoji,
    required Map<String?, dynamic> selectedOptions,
  }) = _FluttermojiState;
}

@riverpod
class FluttermojiNotifier extends _$FluttermojiNotifier {
  @override
  Future<FluttermojiState> build() async {
    return await _loadFluttermojiOptions();
  }

  /// Load the fluttermoji options from Firestore, or defaults if none exist.
  Future<FluttermojiState> _loadFluttermojiOptions() async {
    final options = await getFluttermojiOptions();
    final fluttermojiSvg = getFluttermojiFromOptions(options);

    return FluttermojiState(
      fluttermoji: fluttermojiSvg,
      selectedOptions: options,
    );
  }

  Future<void> setUserFluttermoji(
      Map<String?, dynamic> fluttermojiOptions) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await firestore.collection('users').doc(uid).update({
        'fluttermojiOptions': fluttermojiOptions,
      });
    } catch (e) {
      print("Error saving Fluttermoji options: $e");
    }
  }

  void setSelectedOption(String attributeKey, int optionIndex) {
    final updatedOptions = {
      ...state.value!.selectedOptions,
      attributeKey: optionIndex,
    };

    state = AsyncValue.data(
      state.value!.copyWith(
        selectedOptions: updatedOptions,
        fluttermoji: getFluttermojiFromOptions(updatedOptions),
      ),
    );
  }

  /// Fetches the fluttermoji options from Firestore
  Future<Map<String?, int>> getFluttermojiOptions() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final snapshot = await firestore.collection('users').doc(uid).get();

      if (snapshot.exists) {
        return (snapshot.data()?['fluttermojiOptions'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, value as int));
      } else {
        final defaultOptions =
            Map<String?, int>.from(defaultFluttermojiOptions);
        await setUserFluttermoji(defaultOptions);
        return defaultOptions;
      }
    } catch (e) {
      print("Error getting Fluttermoji options: $e");
      return Map<String?, int>.from(defaultFluttermojiOptions);
    }
  }

  String _getFluttermojiProperty(String type, Map<String?, dynamic> options) {
    final index = options[type] as int;
    return fluttermojiProperties[type]!.property!.elementAt(index);
  }

  /// Generates the complete SVG string based on `selectedOptions`
  String getFluttermojiFromOptions(Map<String?, dynamic> options) {
    String _fluttermojiStyle =
        fluttermojiStyle[_getFluttermojiProperty('style', options)]!;
    String _clothe = Clothes.generateClothes(
        clotheType: _getFluttermojiProperty('clotheType', options),
        clColor: _getFluttermojiProperty('clotheColor', options))!;
    String _facialhair = FacialHair.generateFacialHair(
        facialHairType: _getFluttermojiProperty('facialHairType', options),
        fhColor: _getFluttermojiProperty('facialHairColor', options))!;
    String _mouth = mouth[_getFluttermojiProperty('mouthType', options)];
    String _nose = nose['Default'];
    String _eyes = eyes['${_getFluttermojiProperty('eyeType', options)}'];
    String _eyebrows =
        eyebrow['${_getFluttermojiProperty('eyebrowType', options)}'];
    String _accessory =
        accessories[_getFluttermojiProperty('accessoriesType', options)];
    String _hair = HairStyle.generateHairStyle(
        hairType: _getFluttermojiProperty('topType', options),
        hColor: _getFluttermojiProperty('hairColor', options))!;
    String _skin = skin[_getFluttermojiProperty('skinColor', options)];
    String _completeSVG = '''
<svg width="264px" height="280px" viewBox="0 0 264 280" version="1.1"
xmlns="http://www.w3.org/2000/svg"
xmlns:xlink="http://www.w3.org/1999/xlink">
<desc>Fluttermoji on pub.dev</desc>
<defs>
<circle id="path-1" cx="120" cy="120" r="120"></circle>
<path d="M12,160 C12,226.27417 65.72583,280 132,280 C198.27417,280 252,226.27417 252,160 L264,160 L264,-1.42108547e-14 L-3.19744231e-14,-1.42108547e-14 L-3.19744231e-14,160 L12,160 Z" id="path-3"></path>
<path d="M124,144.610951 L124,163 L128,163 L128,163 C167.764502,163 200,195.235498 200,235 L200,244 L0,244 L0,235 C-4.86974701e-15,195.235498 32.235498,163 72,163 L72,163 L76,163 L76,144.610951 C58.7626345,136.422372 46.3722246,119.687011 44.3051388,99.8812385 C38.4803105,99.0577866 34,94.0521096 34,88 L34,74 C34,68.0540074 38.3245733,63.1180731 44,62.1659169 L44,56 L44,56 C44,25.072054 69.072054,5.68137151e-15 100,0 L100,0 L100,0 C130.927946,-5.68137151e-15 156,25.072054 156,56 L156,62.1659169 C161.675427,63.1180731 166,68.0540074 166,74 L166,88 C166,94.0521096 161.51969,99.0577866 155.694861,99.8812385 C153.627775,119.687011 141.237365,136.422372 124,144.610951 Z" id="path-5"></path>
</defs>
<g id="Fluttermoji" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
<g transform="translate(-825.000000, -1100.000000)" id="Fluttermoji/Circle">
<g transform="translate(825.000000, 1100.000000)">''' +
        _fluttermojiStyle +
        '''
<g id="Mask"></g>
<g id="Fluttermoji" stroke-width="1" fill-rule="evenodd">
<g id="Body" transform="translate(32.000000, 36.000000)">

<mask id="mask-6" fill="white">
<use xlink:href="#path-5"></use>
</mask>
<use fill="#D0C6AC" xlink:href="#path-5"></use>''' +
        _skin +
        '''<path d="M156,79 L156,102 C156,132.927946 130.927946,158 100,158 C69.072054,158 44,132.927946 44,102 L44,79 L44,94 C44,124.927946 69.072054,150 100,150 C130.927946,150 156,124.927946 156,94 L156,79 Z" id="Neck-Shadow" opacity="0.100000001" fill="#000000" mask="url(#mask-6)"></path></g>''' +
        _clothe +
        '''<g id="Face" transform="translate(76.000000, 82.000000)" fill="#000000">''' +
        _mouth +
        _facialhair +
        _nose +
        _eyes +
        _eyebrows +
        _accessory +
        '''</g>''' +
        _hair +
        '''</g></g></g></g></svg>''';

    // Return complete SVG string
    return _completeSVG;
  }

  /// Updates the fluttermoji preview based on the current `selectedOptions`
  void updatePreview({String? fluttermojiNew}) {
    state = AsyncValue.data(state.value!.copyWith(
      fluttermoji: fluttermojiNew ??
          getFluttermojiFromOptions(state.value!.selectedOptions),
    ));
  }

  /// Restore the fluttermoji state from Firestore
  Future<void> restoreState() async {
    final options = await getFluttermojiOptions();
    final fluttermojiSvg = getFluttermojiFromOptions(options);

    state = AsyncValue.data(state.value!.copyWith(
      fluttermoji: fluttermojiSvg,
      selectedOptions: options,
    ));
  }

  /// Stores the fluttermoji and selected options in Firestore
  Future<void> setFluttermoji({String fluttermojiNew = ''}) async {
    final firestore = FirebaseFirestore.instance;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final fluttermoji = fluttermojiNew.isEmpty
        ? getFluttermojiFromOptions(state.value!.selectedOptions)
        : fluttermojiNew;

    await firestore.collection('users').doc(uid).set({
      'fluttermojiOptions': state.value!.selectedOptions,
    }, SetOptions(merge: true));

    state = AsyncValue.data(state.value!.copyWith(fluttermoji: fluttermoji));
  }

  /// Generates compnonent SVG string for an individual component
  /// to display as a preview
  String getComponentSVG(String? attributeKey, int? attributeValueIndex) {
    switch (attributeKey) {
      case 'clotheType':
        return '''<svg width="100px" height="120px" viewBox="30 100 200 250" >''' +
            Clothes.generateClothes(
                clotheType: ClotheType.elementAt(attributeValueIndex!),
                clColor:
                    ClotheColor[state.value!.selectedOptions['clotheColor']])! +
            '''</svg>''';

      case 'clotheColor':
        return '''<svg width="120px" height="120px" > 
                <circle cx="60" cy="60" r="35" stroke="black" stroke-width="1" fill="''' +
            Clothes.clotheColor[ClotheColor[attributeValueIndex!]] +
            '''"/></svg>''';

      case 'topType':
        if (attributeValueIndex == 0) return emptySVGIcon;
        return '''<svg width="20px" width="100px" height="100px" viewBox="10 0 250 250">''' +
            HairStyle.generateHairStyle(
                hairType: TopType[attributeValueIndex!],
                hColor: HairColor[state.value!.selectedOptions['hairColor']])! +
            '''</svg>''';

      case 'hairColor':
        return '''<svg width="120px" height="120px" > 
                <circle cx="60" cy="60" r="30" stroke="black" stroke-width="1" fill="''' +
            HairStyle.hairColor[HairColor.elementAt(attributeValueIndex!)] +
            '''"/> </svg>''';

      case 'facialHairType':
        if (attributeValueIndex == 0) return emptySVGIcon;
        return '''<svg width="20px" height="20px" viewBox="0 -40 112 180" >''' +
            FacialHair.generateFacialHair(
                facialHairType: FacialHairType[attributeValueIndex!],
                fhColor: FacialHairColor[
                    state.value!.selectedOptions['facialHairColor']])! +
            '''</svg>''';

      case 'facialHairColor':
        return '''<svg width="120px" height="120px" > 
                <circle cx="60" cy="60" r="30" stroke="black" stroke-width="1" fill="''' +
            FacialHair.facialHairColor[FacialHairColor[attributeValueIndex!]] +
            '''"/></svg>''';

      case 'eyeType':
        return '''<svg width="20px" height="20px" viewBox="-3 -30 120 120">''' +
            eyes[EyeType[attributeValueIndex!]] +
            '''</svg>''';

      case 'eyebrowType':
        return '''<svg width="20px" height="20px" viewBox="-3 -50 120 120">''' +
            eyebrow[EyebrowType[attributeValueIndex!]] +
            '''</svg>''';

      case 'mouthType':
        return '''<svg width="20px" height="20px" viewBox="0 10 120 120">''' +
            mouth[MouthType[attributeValueIndex!]] +
            '''</svg>''';

      case 'accessoriesType':
        if (attributeValueIndex == 0) return emptySVGIcon;
        return '''<svg width="20px" height="20px" viewBox="-3 -50 120 170" >''' +
            accessories[AccessoriesType[attributeValueIndex!]] +
            '''</svg>''';

      case 'skinColor':
        return '''<svg width="264px" height="280px" viewBox="0 0 264 280" version="1.1"
xmlns="http://www.w3.org/2000/svg"
xmlns:xlink="http://www.w3.org/1999/xlink">
<desc>Fluttermoji Skin Preview</desc>
<defs>
<circle id="path-1" cx="120" cy="120" r="120"></circle>
<path d="M12,160 C12,226.27417 65.72583,280 132,280 C198.27417,280 252,226.27417 252,160 L264,160 L264,-1.42108547e-14 L-3.19744231e-14,-1.42108547e-14 L-3.19744231e-14,160 L12,160 Z" id="path-3"></path>
<path d="M124,144.610951 L124,163 L128,163 L128,163 C167.764502,163 200,195.235498 200,235 L200,244 L0,244 L0,235 C-4.86974701e-15,195.235498 32.235498,163 72,163 L72,163 L76,163 L76,144.610951 C58.7626345,136.422372 46.3722246,119.687011 44.3051388,99.8812385 C38.4803105,99.0577866 34,94.0521096 34,88 L34,74 C34,68.0540074 38.3245733,63.1180731 44,62.1659169 L44,56 L44,56 C44,25.072054 69.072054,5.68137151e-15 100,0 L100,0 L100,0 C130.927946,-5.68137151e-15 156,25.072054 156,56 L156,62.1659169 C161.675427,63.1180731 166,68.0540074 166,74 L166,88 C166,94.0521096 161.51969,99.0577866 155.694861,99.8812385 C153.627775,119.687011 141.237365,136.422372 124,144.610951 Z" id="path-5"></path>
</defs>
	<g id="Fluttermoji" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
		<g transform="translate(-825.000000, -1100.000000)" id="Fluttermoji/Circle">
			<g transform="translate(825.000000, 1100.000000)">
				<g id="Mask"></g>
        <g id="Fluttermoji" stroke-width="1" fill-rule="evenodd">
					<g id="Body" transform="translate(32.000000, 36.000000)">
						<mask id="mask-6" fill="white">
							<use xlink:href="#path-5"></use>
						</mask>
						<use fill="#D0C6AC" xlink:href="#path-5"></use>
        ''' +
            skin[SkinColor[attributeValueIndex!]] +
            '''	<path d="M156,79 L156,102 C156,132.927946 130.927946,158 100,158 C69.072054,158 44,132.927946 44,102 L44,79 L44,94 C44,124.927946 69.072054,150 100,150 C130.927946,150 156,124.927946 156,94 L156,79 Z" id="Neck-Shadow" opacity="0.100000001" fill="#000000" mask="url(#mask-6)"></path>
				</g>
		</g>
	</g>
</svg>''';

      case 'style':
        return '''<svg width="264px" height="280px" viewBox="0 0 264 280" version="1.1"
xmlns="http://www.w3.org/2000/svg"
xmlns:xlink="http://www.w3.org/1999/xlink">
<desc>Fluttermoji Skin Preview</desc>
<defs>
<circle id="path-1" cx="120" cy="120" r="120"></circle>
<path d="M12,160 C12,226.27417 65.72583,280 132,280 C198.27417,280 252,226.27417 252,160 L264,160 L264,-1.42108547e-14 L-3.19744231e-14,-1.42108547e-14 L-3.19744231e-14,160 L12,160 Z" id="path-3"></path>
<path d="M124,144.610951 L124,163 L128,163 L128,163 C167.764502,163 200,195.235498 200,235 L200,244 L0,244 L0,235 C-4.86974701e-15,195.235498 32.235498,163 72,163 L72,163 L76,163 L76,144.610951 C58.7626345,136.422372 46.3722246,119.687011 44.3051388,99.8812385 C38.4803105,99.0577866 34,94.0521096 34,88 L34,74 C34,68.0540074 38.3245733,63.1180731 44,62.1659169 L44,56 L44,56 C44,25.072054 69.072054,5.68137151e-15 100,0 L100,0 L100,0 C130.927946,-5.68137151e-15 156,25.072054 156,56 L156,62.1659169 C161.675427,63.1180731 166,68.0540074 166,74 L166,88 C166,94.0521096 161.51969,99.0577866 155.694861,99.8812385 C153.627775,119.687011 141.237365,136.422372 124,144.610951 Z" id="path-5"></path>
</defs>
	<g id="Fluttermoji" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
    <g transform="translate(-825.000000, -1100.000000)" id="Fluttermoji/Circle">
			<g transform="translate(825.000000, 1100.000000)">''' +
            fluttermojiStyle[FluttermojiStyle[attributeValueIndex!]]! +
            '''<g id="Mask"></g>
        <g id="Fluttermoji" stroke-width="1" fill-rule="evenodd">
					<g id="Body" transform="translate(32.000000, 36.000000)">
						<mask id="mask-6" fill="white">
							<use xlink:href="#path-5"></use>
						</mask>
						<use fill="#D0C6AC" xlink:href="#path-5"></use>
        ''' +
            skin[SkinColor[1]] +
            '''	<path d="M156,79 L156,102 C156,132.927946 130.927946,158 100,158 C69.072054,158 44,132.927946 44,102 L44,79 L44,94 C44,124.927946 69.072054,150 100,150 C130.927946,150 156,124.927946 156,94 L156,79 Z" id="Neck-Shadow" opacity="0.100000001" fill="#000000" mask="url(#mask-6)"></path>
				</g>
		</g>
	</g>
</svg>''';

      default:
        return emptySVGIcon;
    }
  }
}
