// @flow
import _ from 'lodash';
import React from 'react';
import ReactDOM from 'react-dom';

const KNOB_SIZE = 12;
const BORDER_SIZE = 1;

type Props = {
  onScrollChange: (value: number) => void,
  min: number,
  max: number,
};

type State = {
  value: number,
};

class Scroller extends React.PureComponent<Props, State> {
  constructor() {
    super();
    this.state = {
      value: 0,
    };
  }

  onMove(event: SyntheticDragEvent<Element>) {
    event.preventDefault();
    this.scroll(event);
  }

  onDragEnd(event: SyntheticDragEvent<Element>) {
    event.preventDefault();
    this.scroll(event);
  }

  scroll(event: SyntheticDragEvent<Element>) {
    const { clientX } = event;
    const { min, max } = this.props;

    /* eslint-disable react/no-find-dom-node */
    const node: null | Element | Text = ReactDOM.findDOMNode(this);
    /* eslint-enable react/no-find-dom-node */
    if (node === null || node instanceof Text) {
      return;
    }
    const rect: ClientRect = node.getBoundingClientRect();
    const mappedX = clientX - rect.left;
    const maxWidth = rect.width;
    const scaledX = (mappedX / maxWidth) * (max - min) + min;

    this.move(mappedX, scaledX, maxWidth);
  }

  move(x: number, vx: number, maxWidth: number) {
    const { onScrollChange } = this.props;
    const value = _.min([
      _.max([x, 0]),
      maxWidth - KNOB_SIZE - 2 * BORDER_SIZE,
    ]);

    onScrollChange(vx);
    this.setState({
      value,
    });
  }

  render() {
    const { value } = this.state;

    return (
      <div className="c-scroller">
        <div
          className="c-scroller__knob"
          style={{
            left: value,
          }}
        />
        <div
          className="c-scroller__drag"
          draggable
          onDrag={(event: SyntheticDragEvent<HTMLDivElement>) => {
            this.onMove(event);
          }}
          onDragEnd={(event: SyntheticDragEvent<HTMLDivElement>) => {
            this.onDragEnd(event);
          }}
          style={{
            left: value,
          }}
        />
      </div>
    );
  }
}

export default Scroller;