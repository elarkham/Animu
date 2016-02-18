import { IndexRoute, Route }    from 'react-router';
import React                    from 'react';
import MainLayout               from '../layouts/main';
import AuthenticatedContainer   from '../containers/authenticated';
import HomeIndex                from '../views/home/index';
import Register                 from '../views/authenticate/register';
import Login                    from '../views/authenticate/login';

export default (
  <Route component={MainLayout}>
    <Route path="/register" component={Register} />
    <Route path="/login"    component={Login} />

    <Route path="/" component={AuthenticatedContainer} >
      <IndexRoute component={HomeIndex} />
    </Route>
  </Route>
);
