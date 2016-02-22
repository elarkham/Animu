import React              from 'react';
import { connect }        from 'react-redux';
import { Link }           from 'react-router';
import { routeActions }   from 'react-router-redux';

import SessionActions from '../actions/session';

class SideBar extends React.Component {
  render() {
    return (
      <aside id="sidebar">

        <h1 className="logo"><Link to='/'>ANIMU</Link></h1>

        <ul className="menu-list">
          <li><Link to='/channel'  className="menu-item">Live Stream</Link></li>
          <li><Link to='/recent'   className="menu-item">Recent</Link></li>
          <li><Link to='/seasonal' className="menu-item">Seasonal</Link></li>
          <li><Link to='/series'   className="menu-item">Series</Link></li>
          <li><Link to='/movies'   className="menu-item">Movies</Link></li>
          <li><Link to='/ova'      className="menu-item">OVA</Link></li>
        </ul>
      </aside>
    );
  }
}

const mapStateToProps = (state) => ({
  current_user: state.session.current_user,
});

export default connect(mapStateToProps)(SideBar);

