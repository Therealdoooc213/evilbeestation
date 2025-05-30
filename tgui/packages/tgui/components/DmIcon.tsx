import { Component, ReactNode } from 'react';
import { resolveAsset } from '../assets';
import { fetchRetry } from '../http';
import { BoxProps } from './Box';
import { Image } from './Image';

export enum Direction {
  NORTH = 1,
  SOUTH = 2,
  EAST = 4,
  WEST = 8,
  NORTHEAST = NORTH | EAST,
  NORTHWEST = NORTH | WEST,
  SOUTHEAST = SOUTH | EAST,
  SOUTHWEST = SOUTH | WEST,
}

type DmIconProps = {
  /** Required: The path of the icon */
  icon: string;
  /** Required: The state of the icon */
  icon_state: string;
} & Partial<{
  /** Facing direction. See direction enum. Default is South */
  direction: Direction;
  /** Fallback icon. */
  fallback: ReactNode;
  /** Frame number. Default is 1 */
  frame: number;
  /** Movement state. Default is false */
  movement: any;
}> &
  BoxProps;

type DmIconState = {
  iconRef: string;
};

let refMap: Record<string, string> | undefined;

export class DmIcon extends Component<DmIconProps, DmIconState> {
  state: DmIconState = {
    iconRef: '',
  };

  async fetchRefMap() {
    const response = await fetchRetry(resolveAsset('icon_ref_map.json'));
    const data = await response.json();
    refMap = data;
    this.setState({ iconRef: data[this.props.icon] });
  }

  componentDidMount() {
    this.updateOrFetchRefMap();
  }

  componentDidUpdate(prevProps: DmIconProps) {
    if (prevProps.icon !== this.props.icon) {
      this.updateOrFetchRefMap();
    }
  }

  updateOrFetchRefMap() {
    if (refMap) {
      this.setState({ iconRef: refMap[this.props.icon] });
    } else {
      this.fetchRefMap();
    }
  }

  render() {
    const { className, direction = Direction.SOUTH, fallback, frame = 1, icon_state, movement = false, ...rest } = this.props;
    const { iconRef } = this.state;

    const query = `${iconRef}?state=${icon_state}&dir=${direction}&movement=${!!movement}&frame=${frame}`;

    if (!iconRef) return fallback || null;

    return <Image fixErrors src={query} {...rest} />;
  }
}
