import { createBackendModule } from '@backstage/backend-plugin-api';
import {
  authProvidersExtensionPoint,
  createProxyAuthProviderFactory,
  type ProxyAuthenticator,
} from '@backstage/plugin-auth-node';
import type { IncomingMessage } from 'http';

function firstHeader(
  req: IncomingMessage,
  ...names: string[]
): string | undefined {
  for (const name of names) {
    const val = req.headers[name.toLowerCase()];
    if (val) return Array.isArray(val) ? val[0] : val;
  }
  return undefined;
}

// Tries X-Forwarded-* (oauth2-proxy), X-Auth-Request-* (oauth2-proxy alt),
// then Remote-* (Authelia direct forward-auth), in that order.
const flexibleProxyAuthenticator: ProxyAuthenticator = {
  initialize() {},
  async authenticate({ req }: { req: IncomingMessage }) {
    const username = firstHeader(
      req,
      'x-forwarded-user',
      'x-auth-request-user',
      'remote-user',
    );
    if (!username) return undefined;

    const email = firstHeader(
      req,
      'x-forwarded-email',
      'x-auth-request-email',
      'remote-email',
    );

    return {
      fullProfile: {
        provider: 'oauth2Proxy',
        id: username,
        displayName: username,
        emails: email ? [{ value: email }] : [],
      },
    };
  },
};

export const oauth2ProxyAuthModule = createBackendModule({
  pluginId: 'auth',
  moduleId: 'custom-oauth2-proxy',
  register(reg) {
    reg.registerInit({
      deps: { providers: authProvidersExtensionPoint },
      async init({ providers }) {
        providers.registerProvider({
          providerId: 'oauth2Proxy',
          factory: createProxyAuthProviderFactory({
            authenticator: flexibleProxyAuthenticator,
            async signInWithCatalogUser({ result }, ctx) {
              return ctx.signInWithCatalogUser({
                entityRef: { name: result.fullProfile.id },
              });
            },
          }),
        });
      },
    });
  },
});
