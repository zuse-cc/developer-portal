import { createApp } from '@backstage/frontend-defaults';
import catalogPlugin from '@backstage/plugin-catalog/alpha';
import { navModule } from './modules/nav';
import { SignInPageBlueprint } from '@backstage/plugin-app-react';
import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { ProxiedSignInPage, SignInPage } from '@backstage/core-components';

import { configApiRef, useApi } from '@backstage/core-plugin-api';

const signInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => (props: any) => {
      const configApi = useApi(configApiRef);
      if (configApi.has('auth.providers.oauth2Proxy')) {
        return <ProxiedSignInPage {...props} provider="oauth2Proxy" />
      }
      return <SignInPage {...props} providers={['guest']} />
    }
  },
});

export default createApp({
  features: [
    catalogPlugin, 
    navModule, 
    createFrontendModule({pluginId: 'app', extensions: [signInPage]})],
});
