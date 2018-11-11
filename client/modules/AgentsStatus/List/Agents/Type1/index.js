import { connect } from 'react-redux';
import Type1 from './Type1';
import * as queries from './queries';

const mapStateToProps = (state) => {
  const { agent } = state;
  const { id, name } = agent;

  const temperature = queries.getTemperature(agent);
  const isMotion = queries.isMotion(agent);
  const isGas = queries.isGas(agent);

  return {
    id,
    name,
    temperature,
    isMotion,
    isGas,
  };
};

const mapDispatchToProps = () => ({});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Type1);
