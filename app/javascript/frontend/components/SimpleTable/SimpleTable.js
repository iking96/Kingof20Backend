import React, { useMemo } from "react";

const Row = React.memo(({ columns, row, rowIdx, onRowClick }) => {
  // Ignore link clicks to avoid navigation issues
  const handleRowClick = onRowClick
    ? e => e.target.tagName !== "A" && onRowClick(e, row)
    : null;

  return (
    <tr onClick={handleRowClick} key={row.id}>
      {columns.map((column, columnIdx) => (
        <td key={column.key}>
          {column.render ? column.render(row, rowIdx) : row[column.key]}
        </td>
      ))}
    </tr>
  );
});

const Header = React.memo(({ columns }) => (
  <thead>
    <tr>
      {columns.map(column => (
        <th key={column.key}>{column.name}</th>
      ))}
    </tr>
  </thead>
));

const Body = React.memo(({ columns, rows, resourceName, onRowClick }) => (
  <tbody>
    {rows.length ? (
      rows.map((row, rowIdx) => (
        <Row
          columns={columns}
          row={row}
          resourceName={resourceName}
          onRowClick={onRowClick}
          key={row.id}
        />
      ))
    ) : (
      <tr>
        <td colSpan={999}>No {resourceName || items}</td>
      </tr>
    )}
  </tbody>
));

const SimpleTable = ({ columns, rows, resourceName, onRowClick }) => {
  return (
    <table>
      <Header columns={columns} />
      <Body
        columns={columns}
        rows={rows}
        resourceName={resourceName}
        onRowClick={onRowClick}
      />
    </table>
  );
};

export default React.memo(SimpleTable);
