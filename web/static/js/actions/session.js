import { routeActions }                   from 'react-router-redux';
import { Socket }                         from '../phoenix';
import { httpGet, httpPost, httpDelete }  from '../utils';

import Constants                          from '../constants';

function setCurrentUser(dispatch, user){
  dispatch({
    type: Constants.CURRENT_USER,
    current_user: user,
  });
}

const Actions = {
  login: (username, password) => {
    return dispatch => {
      const data = {
        session: {
          username: username,
          password: password,
        },
      };

      httpPost('/api/v1/session', data)

      .then((data) => {
        localStorage.setItem('AuthToken', data.jwt);
        setCurrentUser(dispatch, data.user);
        dispatch(routeActions.push('/'));
      })

      .catch((error) => {
        console.log(error);
        error.response.json()
        .then(( errorJSON ) => {
          dispatch({
            type: Constants.SESSION_ERROR,
            error: errorJSON.error,
          });
        });
      });

    };

  },

  logout: () => {
    return dispatch => {
      httpDelete('/api/v1/session')
      .then((data) => {
        localStorage.removeItem('AuthToken');

        dispatch({ type: Constants.USER_LOGGED_OUT});
        dispatch( routeActons.push('/login') );
      })
      .catch(function(error){
        console.log(error);
      });
    };
  },

  currentUser: () => {
    return dispatch => {
      const authToken = localStorage.getItem('AuthToken');

      httpGet('/api/v1/current_user')
      .then(function(data){
        setCurrentUser(dispatch, data);
      })
      .catch(function(error){
        console.log(error);
        dispatch(routeActions.push('/login'));
      });

    };
  },

};

export default Actions;
