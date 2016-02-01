import React            from 'react';
import { connect }      from 'react-redux';
import Actions          from '../actions/session';
import { routeActions } from 'react-router-redux';
import Header           from '../layouts/header';

class AuthenticatedContainer extends React.Component {
    componentDidMount() {
        const { dispatch, current_user } = this.props;
        const AuthToken = localStorage.getItem('AuthToken');

        if( AuthToken && !current_user ) {
            dispatch(Actions.currentUser());
        } else {
            dispatch(routeActions.push('/login'));
        }
    }

    render(){
        const { current_user, dispatch } = this.props;

        if( !current_user ) return false;

        return (
            <div className = "application-container">
                <Header
                    currentUser={current_user}
                    dispatch={dispatch} />
                <div className="main-container">
                    {this.props.children}
                </div>
            </div>
        );
    }

}

const mapStateToProps = (state) => ({
    current_user: state.session.current_user,
});

export default connect(mapStateToProps)(AuthenticatedContainer);
