import React, {PropTypes}   from 'react';
import { connect }          from 'react-redux';
import { Link }             from 'react-router';

import { setDocumentTitle } from '../../utils';
import Actions              from '../../actions/session';

class Login extends React.Component {
    componentDidMount() {
        setDocumentTitle('Login');
    }

    _handleSubmit(e) {
        e.preventDefault();

        const {username, password} = this.refs;
        const {dispatch} = this.props;

        dispatch(Actions.login(username.value, password.value));
    }

    _renderError() {
        const { error } = this.props;

        if (!error) return false;

        return (
            <div className='error'>
                {error}
            </div>
        );
    }

    render() {
        return (
            <div className='view-container session new'>
                <main>
                    <header>
                        <div className="logo" />
                    </header>
                    <form onSubmit={::this._handleSubmit}>
                        {::this._renderError()}
                        <div className="field">
                            <input ref="username"
                                   type="text"
                                   placholder="Username"
                                   required="true" />
                        </div>
                        <div className="field">
                            <input ref="password"
                                   type="password"
                                   placholder="Password"
                                   required="true" />
                        </div>
                    </form>
                    <button type="submit">Login</button>
                </main>
                <Link to="/register">Request Account</Link>
            </div>
        )
    }
}

const mapStateToProps = (state) => (
    state.session
);

export default connect(mapStateToProps)(Login);
