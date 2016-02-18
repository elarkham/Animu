import Constants from '../constants';

const initialState = {
  current_user: null,
  error: null
};

export default function reducer(state = initialState, action = {}) {
  switch( action.type ){
    case Constants.CURRENT_USER:
      return { ...state, current_user: action.current_user, error: null };

    case Constants.SESSION_ERROR:
      return { ...state, error: action.error };

    case Constants.USER_LOGGED_OUT:
      return initialState;

    default:
      return state;
  }
}
