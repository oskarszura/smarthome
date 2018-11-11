import _ from 'lodash';
import React from 'react';
import PropTypes from 'prop-types';
import Icon from '../../components/Icon';
import ControlPanel from './ControlPanel';
import List from './List';

const AgentsStatus = (props) => {
  const { error } = props;

  return (
    <div className="agents-status">
      { error && (
        <div className="agents-status__error">
          {error}
        </div>
      )}
      <ControlPanel />
      <List />
    </div>
  );
};

AgentsStatus.propTypes = {
  error: PropTypes.error,
};

export default AgentsStatus;