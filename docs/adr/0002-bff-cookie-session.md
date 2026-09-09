# ADR 0002: BFF cookie session

The browser authenticates to GLX through a gateway-backed server-side session
and an HttpOnly cookie instead of storing bearer tokens in browser storage.
The gateway performs the authorization-code exchange and relays access tokens
only to trusted downstream services.
