import React              from 'react';
import {connect}          from 'react-redux';
import {setDocumentTitle} from '../../utils';

import RecentWatched      from './recent'

class HomeIndex extends React.Component {
  componentDidMount() {
    setDocumentTitle('Home');
  }

  render() {
    const { first_name, last_name } = this.props;

    return (
      <div>
        <RecentWatched />
        <RecentWatched />
        <RecentWatched />
      </div>
    );
  }

}

const mapStateToProps = (state) => ({
  first_name: state.session.current_user.first_name,
  last_name:  state.session.current_user.last_name,
});

export default connect(mapStateToProps)(HomeIndex);
