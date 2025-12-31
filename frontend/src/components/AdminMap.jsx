import React, { useEffect, useRef } from 'react'
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet'
import L from 'leaflet'

const DefaultIcon = L.icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25,41],
  iconAnchor: [12,41],
  popupAnchor: [1,-34],
  shadowSize: [41,41]
})

L.Marker.prototype.options.icon = DefaultIcon

function FitBounds({ reports }){
  const map = useMap()
  useEffect(() => {
    const points = reports
      .map(r => r.location)
      .filter(Boolean)
      .map(l => [l.lat, l.lng])
    if (points.length === 0) return
    if (points.length === 1) return map.setView(points[0], 15)
    map.fitBounds(points, { padding: [50,50] })
  }, [reports, map])
  return null
}

export default function AdminMap({ reports }){
  const center = reports && reports.length && reports[0].location ? [reports[0].location.lat, reports[0].location.lng] : [0,0]

  return (
    <div style={{height:500}}>
      <MapContainer center={center} zoom={13} style={{height:'100%', width:'100%'}}>
        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
        <FitBounds reports={reports} />
        {reports.map(r => r.location && (
          <Marker key={r.id} position={[r.location.lat, r.location.lng]}>
            <Popup>
              <div style={{width:220}}>
                <strong>{r.category}</strong>
                <div style={{fontSize:12, marginTop:6}}>{r.description}</div>
                <div style={{marginTop:6}}><em>Status:</em> {r.status}</div>
              </div>
            </Popup>
          </Marker>
        ))}
      </MapContainer>
    </div>
  )
}
