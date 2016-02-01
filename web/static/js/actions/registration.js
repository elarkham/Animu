import { pushPath }  from 'react-router-redux';
import Constants     from '../constants';
import { httpPost }  from '../utils';

const Actions = {};

Actions.register = (data) => {
    return dispatch => {
        httpPost('api/v1/register', {user:data})

            .then( (data) => {
                localStorage.setItem('AuthToken', data.jwt);

                dispatch({
                    type: Constants.CURRENT_USER,
                    current_user: data.user,
                });

                dispatch(pushPath('/'));
            })

            .catch( (data) => {
                error.response.json().then( (errorJSON) => {
                    dispatch({
                        type: Constants.REGISTRATION_ERROR,
                        errors: errorJSON.errors,
                    });
                });
            });

    };
};

export default Actions;
