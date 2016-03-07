import React from 'react';

class Watched extends React.Component {
  render() {
    let cards = [];
    for( let i = 0; i < 4; i++ ) {
      cards.push(
        <div className="card-v">
          <img src="http://animu.org/assets/video/current_season/Dimension%20W/poster.jpg" />
        </div>
      );
    }

    return (
      <section className="content-box is-black">
        <h3 className="content-box-header">Last Watched</h3>
        <div className="content-box-body">
          {cards}
        </div>
      </section>
    );
  }

}

export default Watched;
