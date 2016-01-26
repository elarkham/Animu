//require('../css/main.scss');
import ../css/main.scss;
import React                    from 'react';
import ReactDOM                 from 'react-dom';
import createBrowserHistory     from 'history/lib/createBrowserHistory';
import { syncReduxAndRouter }   from 'redux-simple-router';
import configureStore           from './store';
import Root                     from './containers/root';

const history = createBrowserHistory();
const store  = configureStore(history);

const target = document.getElementById('main_container');
const node = <Root routerHistory={history} store={store}/>;

ReactDOM.render(node, target);
