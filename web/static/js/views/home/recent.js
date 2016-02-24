import React              from 'react';

class RecentWatched extends React.Component {
  render() {
    let cards = [];
    for( let i = 0; i < 6; i++ ) {
      cards.push(
        <div className="card-v">
          <img src="http://animu.org/assets/video/current_season/Dimension%20W/poster.jpg" />
        </div>
      );
    }

    return (
      <section className="content-box">
        <h3 className="content-box-header">Last Watched</h3>
        <div className="content-box-body">
          {cards}
        </div>
      </section>
    );
  }

}

export default RecentWatched;
