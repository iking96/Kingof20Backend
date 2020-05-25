import React, { useEffect, useState } from "react";
import { useDrag, useDrop } from "react-dnd";

const Tile = ({
  row,
  col,
  value,
  is_starting = false,
  is_temp = false,
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
    <div className={"tile" + `${is_starting ? " starting" : ""}`} ref={drop}>
      {value == 0 ? (
        <></>
      ) : (
        <div className={"decal" + `${is_temp ? " temp" : ""}`} ref={drag}>
          {value}
        </div>
      )}
      {!isOver ? <></> : <div className="highlight" />}
    </div>
  );
};

export default React.memo(Tile);
