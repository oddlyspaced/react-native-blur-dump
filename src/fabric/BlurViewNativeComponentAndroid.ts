import { type ViewProps, type HostComponent, type ColorValue, codegenNativeComponent } from 'react-native';
import type {
  WithDefault,
  Int32,
} from 'react-native/Libraries/Types/CodegenTypes';

interface NativeProps extends ViewProps {
  blurAmount?: WithDefault<Int32, 10>;
  blurType?: WithDefault<'dark' | 'light' | 'xlight', 'dark'>;
  blurRadius?: Int32;
  downsampleFactor?: Int32;
  overlayColor?: ColorValue;
  enabled?: boolean;
  autoUpdate?: boolean;
}

export default codegenNativeComponent<NativeProps>('AndroidBlurView', {
  excludedPlatforms: ['iOS'],
}) as HostComponent<NativeProps>;
