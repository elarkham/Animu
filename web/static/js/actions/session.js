import { routeActions }                   from 'react-router-redux';
import Constants                          from '../constants';
import { Socket }                         from '../phoenix';
import { httpGet, httpPost, httpDelete }  from '../utils';

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
                error.respone.json()
                .then( (errorJSON) => {
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

                dispatch({
                    type: Constants.USER_LOGGED_OUT
                });
            })
            .catch(function(error){
                console.log(error);
            });
        };
    },

    currentUser: () => {
        return dispatch => {
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
