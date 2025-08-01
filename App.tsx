/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import { NewAppScreen } from '@react-native/new-app-screen';
import { StatusBar, StyleSheet, useColorScheme, View } from 'react-native';
import BlurView from './src/BlurView.ios';
// import BlurView from './src/BlurView.android';

function App() {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <View style={styles.container}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <BlurView
        blurRadius={20}
        style={{
          position: 'absolute',
          zIndex: 1,
          opacity: 0.5,
          top: '10%',
          left: '10%',
          width: 100,
          height: 100,
        }}
      />
      <NewAppScreen templateFileName="App.tsx" />
    </View>
  );
}
// 
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default App;
