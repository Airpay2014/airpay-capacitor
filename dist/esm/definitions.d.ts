declare module '@capacitor/core' {
    interface PluginRegistry {
        MyCustomPlugin: MyCustomPluginPlugin;
    }
}
export interface MyCustomPluginPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
    open(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
