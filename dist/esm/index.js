import { registerPlugin } from '@capacitor/core';
const MyCustomPlugin = registerPlugin('MyCustomPlugin', {
    web: () => import('./web').then((m) => new m.MyCustomPluginWeb()),
});
export * from './definitions';
export { MyCustomPlugin };
//# sourceMappingURL=index.js.map