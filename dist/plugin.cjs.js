'use strict';

var core = require('@capacitor/core');

const MyCustomPlugin = core.registerPlugin('MyCustomPlugin', {
    web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.MyCustomPluginWeb()),
});

//import type { MyCustomPluginPlugin } from './definitions';
class MyCustomPluginWeb extends core.WebPlugin {
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    MyCustomPluginWeb: MyCustomPluginWeb
});

exports.MyCustomPlugin = MyCustomPlugin;
//# sourceMappingURL=plugin.cjs.js.map
