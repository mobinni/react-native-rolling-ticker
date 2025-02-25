import { View, StyleSheet, FlatList } from 'react-native';
import { RollingTickerView } from 'react-native-rolling-ticker';
import React, { useEffect, useRef, useState } from 'react';

const App = () => {
  const [value, setValue] = useState(0); // Array of 10,000 values

  useEffect(() => {
    const interval = setInterval(() => {
      setValue(val => val+=1);
    }, 1000);
    return () => clearInterval(interval);
  }, []);
  return (
    <View style={styles.container}>
      <RollingTickerView color="#32a852" value={String(value)} style={styles.box}/>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 50,
  },
  box: {
    width: 200,
    height: 50,
    marginBottom: 10,
  },
});

export default App;
