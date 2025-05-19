import React, { useEffect, useState } from 'react';
import { supabase } from '../supabaseClient';

function Catalogue() {
  const [ressources, setRessources] = useState([]);

  useEffect(() => {
    const fetchRessources = async () => {
      let { data, error } = await supabase
        .from('ressource')
        .select('*');
      if (!error) setRessources(data);
    };
    fetchRessources();
  }, []);

  return (
    <div>
      <h1>Catalogue des ressources</h1>
      <ul>
        {ressources.map(r => (
          <li key={r.id}>{r.nom} - {r.description}</li>
        ))}
      </ul>
    </div>
  );
}

export default Catalogue;
