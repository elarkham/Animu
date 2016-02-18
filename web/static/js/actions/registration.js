import { routeActions }   from 'react-router-redux';
import { httpPost }       from '../utils';
import { setCurrentUser } from './session'
import Constants          from '../constants';

const Actions = {};

Actions.register = (data) => {
  return dispatch => {
    httpPost('api/v1/register', {user:data})
    .then( (data) => {
      localStorage.setItem('AuthToken', data.jwt);

      setCurrentUser(dispatch, data.user);

      dispatch(routeActions.push('/'));
    })

    .catch( (data) => {
      error.response.json()
      .then(( errorJSON ) => {
        dispatch({
          type: Constants.REGISTRATION_ERROR,
          errors: errorJSON.errors,
        });
      });
    });

  };
};

export default Actions;
