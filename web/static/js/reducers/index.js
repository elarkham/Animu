import { combineReducers }  from 'redux';
import { routeReducer }     from 'react-router-redux';
import session              from './session';
import registration         from './registration'

export default combineReducers({
  routing: routeReducer,
  session: session,
  registration: registration,
});
