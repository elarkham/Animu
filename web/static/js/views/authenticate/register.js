import React, {PropTypes}   from 'react';
import { connect }          from 'react-redux';
import { Link }             from 'react-router';

import Actions              from '../../actions/registration';
import { setDocumentTitle,
         renderErrorsFor }  from '../../utils';

class RegistrationNew extends React.Component {
    componentDidMount() {
        setDocumentTitle('Register')
    }

    _handleSubmit(e) {
        e.preventDefault();

        const {dispatch} = this.props;

        const data = {
            first_name: this.refs.first_name.value,
            last_name:  this.refs.last_name.value,
            email:      this.refs.email.value,

            username: this.refs.username.value,
            password: this.refs.password.value,
            password_confirmation: this.refs.password_confirmation.value,
        };

        dispatch(Actions.register(data));
    }

    render() {
        const {errors} = this.props;

        return (
            <div className="view-container registration new" >
                <main>
                    <header>
                        <div className="logo" />
                    </header>

                    <form onSubmit={::this._handleSubmit}>
                        <div className="field">
                            <input ref="first_name"
                                   type="text"
                                   placeholder="First Name"
                                   required={true} />

                            {renderErrorsFor(errors, 'first_name')}
                        </div>

                        <div className="field">
                            <input ref="last_name"
                                   type="text"
                                   placeholder="Last Name"
                                   required={true} />

                            {renderErrorsFor(errors, 'last_name')}
                        </div>

                        <div className="field">
                            <input ref="email"
                                   type="email"
                                   placeholder="Email"
                                   required={false} />

                            {renderErrorsFor(errors, 'email')}
                        </div>

                        <div className="field">
                            <input ref="username"
                                   type="text"
                                   placeholder="Username"
                                   required={true} />

                            {renderErrorsFor(errors, 'username')}
                        </div>

                        <div className="field">
                            <input ref="password"
                                   type="password"
                                   placeholder="Password"
                                   required={true} />

                            {renderErrorsFor(errors, 'password')}
                        </div>

                        <div className="field">
                            <input ref="password_confirmation"
                                   type="password"
                                   placeholder="First Name"
                                   required={true} />

                            {renderErrorsFor(errors, 'password_confirmation')}
                        </div>
                    </form>
                    <button type="submit">Register</button>
                </main>
                <Link to="/login">Login</Link>
            </div>
        );
    }
}
