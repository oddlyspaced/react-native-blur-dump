import {
  type ViewProps,
  type HostComponent,
  type ColorValue,
  codegenNativeComponent,
} from 'react-native';
import type {
  WithDefault,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

interface NativeProps extends ViewProps {
  blurType?: WithDefault<'dark' | 'light', 'dark'>;
  blurAmount?: WithDefault<Int32, 10>;
  reducedTransparencyFallbackColor?: ColorValue;
}

export default codegenNativeComponent<NativeProps>('IOSBlurView', {
  excludedPlatforms: ['android'],
}) as HostComponent<NativeProps>;
