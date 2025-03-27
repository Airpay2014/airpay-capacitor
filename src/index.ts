import { registerPlugin } from '@capacitor/core';

import type { MyCustomPluginPlugin } from './definitions';

const MyCustomPlugin = registerPlugin<MyCustomPluginPlugin>('MyCustomPlugin', {
  web: () => import('./web').then((m) => new m.MyCustomPluginWeb()),
});

export * from './definitions';
export { MyCustomPlugin };
