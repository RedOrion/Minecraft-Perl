package Minecraft::Map;

use Minecraft::Map::Util;

use Mouse;

# use this to pull data when available 
has 'level_nbt_data' => (
    is => 'rw',
    isa => 'Maybe[Minecraft::NBT]',
);

has 'path' => (
    is => 'rw',
    isa => 'String',
);

has 'time' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Long',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('Time') if $self->level_nbt_data;},
    lazy => 1,
);

has 'last_played' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Long',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('LastPlayed') if $self->level_nbt_data},
    lazy => 1,
);

has 'player' => (
    is => 'rw',
    isa => 'Minecraft::Entity::Mob::Player',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('Player') if $self->level_nbt_data},
    lazy => 1,
);

has 'spawn_x' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Int',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('SpawnX') if $self->level_nbt_data},
    lazy => 1,
);

has 'spawn_y' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Int',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('SpawnY') if $self->level_nbt_data},
    lazy => 1,
);

has 'spawn_z' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Int',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('SpawnZ') if $self->level_nbt_data},
    lazy => 1,
);

has 'size_on_disk' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Long',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('SizeOnDisk') if $self->level_nbt_data},
    lazy => 1,
);

has 'random_seed' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Long',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('RandomSeed') if $self->level_nbt_data},
    lazy => 1,
);

has 'snow_covered' => (
    is => 'rw',
    isa => 'Minecraft::NBT::Byte',
    default => sub { 
        my $self = shift;
        return $self->level_nbt_data->get_child_by_name('SnowCovered') if $self->level_nbt_data},
    lazy => 1,
);

has 'chunks' => (
    is => 'rw',
    isa => 'Maybe[HashRef]',
    default => sub {return {}},
);

has 'players' => (
    is => 'rw',
    isa => 'ArrayRef[Minecraft::Entity::Mob]',
    default => sub {return []},
    lazy => 1,
);

sub _chunk_key {
    my ($self, $chunk_x, $chunk_z) = @_;
    return join(',', $chunk_x, $chunk_z);
}

sub get_chunk {
    my ($self, $chunk_x, $chunk_z) = @_;

    my $key = $self->_chunk_key($chunk_x, $chunk_z);

    if (my $chunk = $self->chunks->{$key}) {
        return $chunk;
    }

    if ($self->path && -e $self->path) {
        my $chunk = Minecraft::Map::Util::load_chunk_from_file({
            world_path => $self->path,
            chunk_x => $chunk_x,
            chunk_z => $chunk_z,
        });
        $self->chunks->{$key} = $chunk if $chunk;
    }
}

sub set_chunk {
    my ($self, $chunk_x, $chunk_z, $chunk) = @_;
    return unless defined $chunk_x && defined $chunk_z && defined $chunk;

    my $key = $self->_chunk_key($chunk_x, $chunk_z);
    $self->chunks->{$key} = $chunk;

    return $chunk
}

1;
