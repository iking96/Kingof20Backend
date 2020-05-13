import React, { useEffect, useState } from "react";
import { useDrag, useDrop } from "react-dnd";

const Tile = ({
  row,
  col,
  value,
  styleName = "",
  canDrag = () => {},
  canDrop = () => {},
  didDrop = () => {},
  handleDrop = () => {}
}) => {
  const [{ isDragging }, drag] = useDrag({
    item: { type: "tile", value: value },
    collect: monitor => ({
      isDragging: !!monitor.isDragging()
    }),
    canDrag: monitor => canDrag(),
    end: (_, monitor) => monitor.didDrop() && didDrop()
  });

  const [{ isOver }, drop] = useDrop({
    accept: "tile",
    drop: (_, monitor) => handleDrop(monitor.getItem().value),
    collect: monitor => ({
      isOver: !!monitor.isOver()
    }),
    canDrop: monitor => canDrop()
  });

  return (
    <div className={"tile" + ` ${styleName}`} ref={drop}>
      {value == 0 ? (
        <></>
      ) : (
        <div className="decal" ref={drag}>
          {value}
        </div>
      )}
      {!isOver ? <></> : <div className="highlight" />}
    </div>
  );
};

export default React.memo(Tile);
