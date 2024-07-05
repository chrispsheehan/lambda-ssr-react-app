import {Link} from 'react-router-dom';

function Navbar() {
  return (
    <div>
      <Link to="/home">Home</Link>
      <Link to="/about">About</Link>
    </div>
  );
}

export default Navbar;