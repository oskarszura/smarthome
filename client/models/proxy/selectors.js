// @flow
/* eslint-disable import/prefer-default-export */
export const getWsClient = (state: State): WebSocket => {
  return state.proxy.wsClient;
};
/* eslint-enable import/prefer-default-export */