import React from 'react';

class Seasional extends React.Component {
  render() {
    let cards = [];
    for( let i = 0; i < 4; i++ ) {
      cards.push(
        <div className="card-h">
          <img src="http://animu.org/assets/video/archive/Kinos%20Journey/poster.jpg" />
          <section className="card-content">
            <h4 className="card-title">Kino's Journey </h4>
            <h6 className="card-subtitle">Kino no Tabi: The Beautiful World</h6>
            <p  className="card-body">
              Based on a hit light novel series by Keiichi Sigsawa, the philosophical Kino's Journey employs the time-honored motif of the road trip as a vehicle for self-discovery and universal truth. Deeply meditative and cooler than zero, the series follows the existential adventures of the apt marksman Kino along with talking motorcycle Hermes as they travel the world and learn much about themselves in the process. Imaginative, thought-provoking, and sometimes disturbing, Kino's journey is documented in an episodic style with an emphasis on atmosphere rather than action or plot, though still prevalent.

            </p>
          </section>
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

export default Seasional;
